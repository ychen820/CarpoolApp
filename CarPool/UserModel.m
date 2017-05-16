//
//  UserModel.m
//  CarPool
//
//  Created by Nathan Chen on 5/4/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel
+(instancetype)userWithDict:(NSDictionary *)dict{
    UserModel *user=[[UserModel alloc]init];
    if(user){
        user.age=dict[@"age"];
        user.firstName=dict[@"firstName"];
        user.lastName=dict[@"lastName"];
        user.photoURL=dict[@"photoURL" ];
        user.instanceID = dict[@"instanceID"];
        user.posts = dict[@"posts"];
    }
    return user;
}
-(instancetype)init{
    self=[super init];
    if(self){
        self.age=@"";
        self.firstName=@"";
        self.lastName=@"";
        self.photoURL=@"";
        self.uid=@"";
        self.instanceID = @"";
    }
    return self;
}
@end
