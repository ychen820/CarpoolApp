//
//  PostViewCell.m
//  CarPool
//
//  Created by Nathan Chen on 5/1/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "PostViewCell.h"

@implementation PostViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.postContentView.layer setCornerRadius:20.0];
    [self.postContentView.layer setMasksToBounds:YES];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
