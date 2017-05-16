//
//  FireBaseManager.m
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/15/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "FireBaseManager.h"

@implementation FireBaseManager
+(instancetype)sharedFireBaseManager{
    static dispatch_once_t sharedFireBaseToken;
    static FireBaseManager *sharedFireBaseManager=nil;
    dispatch_once(&sharedFireBaseToken, ^{
        sharedFireBaseManager=[[FireBaseManager alloc]init];
    });
    return sharedFireBaseManager;
}
-(instancetype)init{
    self=[super init];
    if(self){
        self.databaseRef=[[FIRDatabase database]reference];
        self.storageRef=[[FIRStorage storage]reference];
        self.geoFire=[[GeoFire alloc]initWithFirebaseRef:[self.databaseRef child:@"startLocations"]];
    }
    return self;
}
-(void)firebaseSetValue:(NSDictionary *)value forKey:(NSString *)key{
    [[[self.databaseRef root]child:key]updateChildValues:value];
}
-(void)loadAllDataUnderRef:(FIRDatabaseQuery *)databaseRef withCompletion:(completion)handler{
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [databaseRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if([snapshot hasChildren]){
                NSDictionary *allData=[NSDictionary dictionaryWithDictionary:snapshot.value];
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(allData);
                });
                
            }
        }];
        
        
    });
}
-(FIRDatabaseReference *)getRequestStatusRefForPost:(NSString*)postKey  withUserID:(NSString *)rquesterID{
    NSString *requestStatusLocation = [NSString stringWithFormat:@"posts/%@/requests/%@",postKey,rquesterID];
    FIRDatabaseReference *requestStatusRef = [[self.databaseRef root]child:requestStatusLocation];
    return requestStatusRef;
}
-(FIRDatabaseReference *)getRequestsUnderUserRefForUser:(NSString *)userID withPostKey: (NSString *)postKey{
    NSString *requestsLocation = [NSString stringWithFormat:@"users/%@/requests/%@",userID,postKey];
     FIRDatabaseReference *requestForUserRef = [[self.databaseRef root]child:requestsLocation];
    return requestForUserRef;
}
-(FIRDatabaseReference *)getPostRef:(NSString *)postKey{
    NSString *postLocation = [NSString stringWithFormat:@"posts/%@",postKey];
    return [[self.databaseRef root]child:postLocation];
}
-(FIRDatabaseReference *)getUserRef:(NSString *)userId{
    NSString *userLocation = [NSString stringWithFormat:@"users/%@",userId];
    return [[self.databaseRef root]child:userLocation];
}
-(FIRDatabaseReference *)getDataBaseLocationBtweenUsers:(NSString *)firstUserID andSecondUser:(NSString *)secondUserID {
    
    NSComparisonResult result=[firstUserID compare:secondUserID];
    NSString *msgLocation;
    if(result == NSOrderedAscending)
        msgLocation=[NSString stringWithFormat:@"%@/%@",firstUserID,secondUserID];
    else{
        msgLocation=[NSString stringWithFormat:@"%@/%@",firstUserID,secondUserID];
    }
    return [[[self.databaseRef root]child:@"messages"]child:msgLocation];
}
+(NSDictionary *)createMessageDictWithText:(NSString *)text andSenderID:(NSString *)senderId andSenderDisplayName:(NSString *)senderDisplayName andDate:(NSDate *)date{
    NSDictionary *msgDict=@{@"text":text,
                            @"senderId":senderId,
                            @"senderName":senderDisplayName,
                            @"date":[date description]
                            };
    return msgDict;
}
-(void)deleteRequestUnderPostForUser:(NSString *)userId postKey:(NSString *)postKey requestingUserId:(NSString *)requestingUserId{
    FIRDatabaseReference *requestRef = [self getRequestsUnderUserRefForUser:userId withPostKey:postKey];
    [[requestRef child:requestingUserId]removeValue];
    FIRDatabaseReference *postRef = [self getRequestStatusRefForPost:postKey withUserID:requestingUserId];
    [postRef removeValue];
}
-(void)sendPushNotificationToUser:(UserModel *)user withMessage:(NSString *)message withRiderInfo:(NSDictionary *)riderInfo{
    NSString *instanceToken = user.instanceID;
    if(instanceToken){
    
        
        NSDictionary *notificationDict = @{
                                           @"username": instanceToken,
                                           @"message" : message ,
                                           @"rideinfo" :riderInfo
                                           };
        
        [[[[[FireBaseManager sharedFireBaseManager].databaseRef root] child:@"notificationRequests"]childByAutoId] updateChildValues:notificationDict];
        
    }
}
-(void)createUserObjectWithUid:(NSString *)userId withBlock:(userCompletion)completion{
    FIRDatabaseReference *userRef =[self getUserRef:userId];
    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        UserModel *user = [UserModel userWithDict:snapshot.value];
        user.uid=snapshot.key;
        completion(user);
    }];

}
@end
