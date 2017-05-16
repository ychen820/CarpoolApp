//
//  PostModel.m
//  CarPool
//
//  Created by Nathan Chen on 5/2/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "PostModel.h"

@implementation PostModel
+(instancetype)postWithDictionary:(NSDictionary *)dict{
    PostModel *post=[[PostModel alloc]init];
    if(post){
    NSDateFormatter* dateFormatter =[[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    post.date= [dateFormatter dateFromString:dict[@"date"]];
    post.endName=dict[@"endName"];
    post.startName=dict[@"startName"];
    post.owner=dict[@"owner"];
    post.distance=[NSString stringWithFormat:@"%ld",NSIntegerMax];
        post.carModel=dict[@"carModel"];
    }
    return post;
}
-(instancetype)init{
    self=[super init];
    if(self){
        self.date=nil;
        self.endName=@"";
        self.startName=@"";
        self.owner=@"";
        self.distance=@"";
    }
    return self;
}
@end
