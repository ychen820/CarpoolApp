//
//  LoginManager.m
//  CarPool
//
//  Created by Nathan Chen on 4/28/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "LoginManager.h"

@implementation LoginManager
+(void)fbLogout{
    FBSDKLoginManager *loginManager=[[FBSDKLoginManager alloc]init];
    [loginManager logOut];
}
+(void)ggLogout{
    [[GIDSignIn sharedInstance]signOut];
}

@end
