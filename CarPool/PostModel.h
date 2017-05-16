//
//  PostModel.h
//  CarPool
//
//  Created by Nathan Chen on 5/2/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostModel : NSObject
@property(nonatomic,strong) NSDate *date;
@property(nonatomic,strong) NSString *endName;
@property(nonatomic,strong) NSString *owner;
@property(nonatomic,strong) NSString *startName;
@property(strong,nonatomic)NSString *carModel;
@property(nonatomic,strong)NSString *distance;
@property(nonatomic,strong) NSString *key;
+(instancetype)postWithDictionary:(NSDictionary *)dict;
@end
