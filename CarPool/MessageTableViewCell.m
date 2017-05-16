//
//  MessageTableViewCell.m
//  CarPool
//
//  Created by Nathan Chen on 5/4/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "FireBaseManager.h"
#import "ChatViewController.h"
@implementation MessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)chatButtonAction:(UIButton *)sender {
    NSString *requestingUserID = self.cellInfo[@"requestingUser"];
    NSString *currentUid = [FIRAuth auth].currentUser.uid ;
    NSString *postKey = self.cellInfo[@"postKey"];
    FIRDatabaseReference *postRef = [[FireBaseManager sharedFireBaseManager]getPostRef:postKey];
    [postRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        PostModel *post = [PostModel postWithDictionary:snapshot.value];
        if([post.owner isEqualToString:currentUid]){
            FIRDatabaseReference *requestStatusRef = [[FireBaseManager sharedFireBaseManager]getRequestStatusRefForPost:self.cellInfo[@"postKey"] withUserID:requestingUserID];
            [requestStatusRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                NSString *status = snapshot.value[@"status"];
                if([status isEqualToString:@"requested"]){
                    NSString *acceptingText = [NSString stringWithFormat:@"%@ accepted your request",[FireBaseManager sharedFireBaseManager].currentUser.firstName];
                    [[requestStatusRef child:@"status"]setValue:@"accepted"];
                    FIRDatabaseReference *messageRef = [[[FireBaseManager sharedFireBaseManager]getDataBaseLocationBtweenUsers:[FIRAuth auth].currentUser.uid andSecondUser:self.cellInfo[@"requestingUser"]]childByAutoId];
                    NSDictionary *msgEntry = [FireBaseManager createMessageDictWithText:acceptingText andSenderID:currentUid andSenderDisplayName:currentUid andDate:[NSDate date]];
                    [messageRef setValue:msgEntry];
                    [[FireBaseManager sharedFireBaseManager]createUserObjectWithUid:requestingUserID withBlock:^(UserModel *user) {
                        NSDictionary *riderInfo = @{@"postKey":postKey,@"requestUserId":currentUid,@"type":@"accept"};
                        [[FireBaseManager sharedFireBaseManager]sendPushNotificationToUser:user withMessage:acceptingText withRiderInfo:riderInfo];
                    }];
                                        FIRDatabaseReference *acceptInformationRef = [[FireBaseManager sharedFireBaseManager]getRequestsUnderUserRefForUser:requestingUserID withPostKey:postKey];
                    [[acceptInformationRef child:currentUid]setValue:acceptingText];
                }
                
                
            }];
        }
        FIRDatabaseReference *userRef = [[FireBaseManager sharedFireBaseManager]getUserRef:requestingUserID];
        [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            ChatViewController *cvc = [[ChatViewController alloc]init];
            cvc.senderId = currentUid;
            cvc.senderDisplayName = currentUid;
            UserModel *receipient = [UserModel userWithDict:snapshot.value];
            receipient.uid=snapshot.key;
            cvc.recipient = receipient;
            [self.mvc.navigationController pushViewController:cvc animated:YES];
        }];
        
    }];
}

@end
