//
//  FireBaseManager.h
//  FireBaseDemo
//
//  Created by Nathan Chen on 4/15/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeoFire.h"
#import "PostModel.h"
#import "UserModel.h"
@import Firebase;
typedef void(^completion)(NSDictionary *dataDict);
typedef void(^userCompletion)(UserModel *user);
@interface FireBaseManager : NSObject
@property(strong ,nonatomic)FIRDatabaseReference *databaseRef;
@property(strong,nonatomic)FIRStorageReference *storageRef;
@property(strong,nonatomic)GeoFire *geoFire;
@property(strong,nonatomic)UserModel *currentUser;
+(instancetype)sharedFireBaseManager;
-(void)loadAllDataUnderRef:(FIRDatabaseQuery *)databaseRef withCompletion:(completion)handler;
-(void)firebaseSetValue:(NSDictionary *)value forKey:(NSString *)key;
-(FIRDatabaseReference *)getRequestStatusRefForPost:(NSString*)postKey  withUserID:(NSString *)rquesterID;
-(FIRDatabaseReference *)getRequestsUnderUserRefForUser:(NSString *)userID withPostKey: (NSString *)postKey;
-(FIRDatabaseReference *)getDataBaseLocationBtweenUsers:(NSString *)firstUserID andSecondUser:(NSString *)secondUserID;
+(NSDictionary *)createMessageDictWithText:(NSString *)text andSenderID:(NSString *)senderId andSenderDisplayName:(NSString *)senderDisplayName andDate:(NSDate *)date;
-(FIRDatabaseReference *)getPostRef:(NSString *)postKey;
-(FIRDatabaseReference *)getUserRef:(NSString *)userId;
-(void)deleteRequestUnderPostForUser:(NSString *)userId postKey:(NSString *)postKey requestingUserId:(NSString *)requestingUserId;
-(void)sendPushNotificationToUser:(UserModel *)user withMessage:(NSString *)message withRiderInfo:(NSDictionary *)riderInfo;
-(void)createUserObjectWithUid:(NSString *)userId withBlock:(userCompletion)completion;
@end
