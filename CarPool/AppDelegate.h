//
//  AppDelegate.h
//  CarPool
//
//  Created by Nathan Chen on 4/27/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
@import Firebase;
@import GoogleSignIn;
@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *strDeviceToken;
@property (strong, nonatomic) NSString *instanceID;
-(void)setNetworkIndication:(BOOL)setVisible;
@end

