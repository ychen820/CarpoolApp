//
//  PostViewCell.h
//  CarPool
//
//  Created by Nathan Chen on 5/1/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *startLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *postContentView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end
