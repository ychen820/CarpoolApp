//
//  CarpoolTableViewController.h
//  CarPool
//
//  Created by Nathan Chen on 4/29/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarpoolTableViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(void)loadAllPostsWithKeys:(NSArray *)keys fromDate:(NSDate *)date withCompa:(NSComparator) comparetor;
@end
