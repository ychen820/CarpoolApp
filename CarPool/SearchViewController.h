//
//  SearchViewController.h
//  CarPool
//
//  Created by Nathan Chen on 4/29/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostViewController.h"
@interface SearchViewController : UIViewController<UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource>
@property(weak,nonatomic)UITextField *textfield;
@property(weak,nonatomic)NSString *address;
@property(weak,nonatomic)PostViewController *pvc;

@end
