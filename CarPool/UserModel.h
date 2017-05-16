//
//  UserModel.h
//  CarPool
//
//  Created by Nathan Chen on 5/4/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
@property(nonatomic,strong) NSString *firstName;
@property(nonatomic,strong) NSString *lastName;
@property(nonatomic,strong) NSString *age;
@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSString *photoURL;
@property(nonatomic,strong) NSString *instanceID;
@property(nonatomic,strong) NSDictionary *posts;
+(instancetype)userWithDict:(NSDictionary *)dict;
@end
