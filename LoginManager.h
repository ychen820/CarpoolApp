//
//  LoginManager.h
//  CarPool
//
//  Created by Nathan Chen on 4/28/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import Firebase;
@import GoogleSignIn;
typedef enum : NSUInteger {
    FACEBOOKLOGIN,
    GOOGLELOGIN,
    
} login_method;
#define KThirdPartyLogin @"KThirdPartyLogin"
@interface LoginManager : NSObject
+(void)fbLogout;
+(void)ggLogout;

@end
