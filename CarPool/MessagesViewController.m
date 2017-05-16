//
//  MessagesViewController.m
//  CarPool
//
//  Created by Nathan Chen on 5/4/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//
#import "UserModel.h"
#import "PostModel.h"
#import "MessagesViewController.h"
#import "FireBaseManager.h"
#import "MessageTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CarPoolDetailViewController.h"
@interface MessagesViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong , nonatomic) NSMutableArray *messageArray;
@property (strong , nonatomic) FIRDatabaseReference *requestRef;
@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageArray = [[NSMutableArray alloc]init];
    [self dataBaseSetup];
   self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];;

    [self loadMessages];
    // Do any additional setup after loading the view.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    cell.mvc = self;
    NSDictionary *entryInfo = [self.messageArray objectAtIndex:indexPath.row];
    cell.cellInfo = entryInfo ;
    FIRDatabaseReference *userRef = [[[FireBaseManager sharedFireBaseManager].databaseRef child:@"users"]child:entryInfo[@"requestingUser"]];
    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        UserModel *requestingUser = [UserModel userWithDict:snapshot.value];
        NSURL *photoURL = [NSURL URLWithString:requestingUser.photoURL];
        cell.requesterImage.layer.cornerRadius = cell.requesterImage.frame.size.height/2;
        [cell.requesterImage.layer setMasksToBounds:YES];
        [cell.requesterImage sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed: @"profile-pictures"] options:SDWebImageProgressiveDownload];
        NSString *labelStr = [NSString stringWithFormat:@"%@",entryInfo[@"message"]];
        cell.customCellLabel.text = labelStr;
        
    }];
    return cell;
}

-(void)dataBaseSetup{
    NSString *requestLocation = [NSString stringWithFormat:@"users/%@/requests",[FIRAuth auth].currentUser.uid];
    self.requestRef = [[[FireBaseManager sharedFireBaseManager].databaseRef root]child:requestLocation];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *postKey = [self.messageArray objectAtIndex:indexPath.row][@"postKey"];
    FIRDatabaseReference *postRef = [[FireBaseManager sharedFireBaseManager]getPostRef:postKey];
    [postRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        PostModel *post = [PostModel postWithDictionary:snapshot.value];
            CarPoolDetailViewController *dvc=[self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
        post.key=snapshot.key;
        dvc.currentPost=post;
        [self.navigationController pushViewController:dvc animated:YES];
    }];
    
}
-(void)loadMessages{
    [self.requestRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSString *postKey = snapshot.key;
        for(NSString *userID in snapshot.value){
            NSDictionary *cellInfo = @{@"postKey":postKey,@"requestingUser":userID,@"message":snapshot.value[userID]};
            [self.messageArray addObject:cellInfo];
            NSIndexPath *newPath=[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
     }];
}
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"deleting request");
        MessageTableViewCell *cellDeleting =[self.tableView cellForRowAtIndexPath:indexPath];
        NSDictionary *cellInfo = cellDeleting.cellInfo;
        [[FireBaseManager sharedFireBaseManager]deleteRequestUnderPostForUser:[FIRAuth auth].currentUser.uid postKey:cellInfo[@"postKey"] requestingUserId:cellInfo[@"requestingUser"]];
        [self.messageArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    return @[deleteAction];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
