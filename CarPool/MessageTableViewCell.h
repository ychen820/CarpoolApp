//
//  MessageTableViewCell.h
//  CarPool
//
//  Created by Nathan Chen on 5/4/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagesViewController.h"
@interface MessageTableViewCell : UITableViewCell
@property(strong,nonatomic) NSDictionary *cellInfo;
@property (weak, nonatomic) IBOutlet UILabel *customCellLabel;
@property (weak, nonatomic) IBOutlet UIImageView *requesterImage;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) MessagesViewController *mvc;
@end

