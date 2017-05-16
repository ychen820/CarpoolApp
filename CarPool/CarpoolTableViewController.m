//
//  CarpoolTableViewController.m
//  CarPool
//
//  Created by Nathan Chen on 4/29/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//
#import "AppDelegate.h"
#import "CarpoolTableViewController.h"
#import "FireBaseManager.h"
#import "PostViewCell.h"
#import "LocationManager.h"
#import "LoginManager.h"
#import "PostModel.h"
#import "CarPoolDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
typedef enum : NSUInteger {
    SORT_BY_DISTANCE,
    SORT_BY_TIME,
    
} mySortOptions;
@interface CarpoolTableViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray *postArray;
@property(nonatomic,assign)FIRDatabaseHandle observerHandle;
@property(nonatomic,strong)FIRDatabaseReference *observerRef;
@end

@implementation CarpoolTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadAllPostsWithKeys:nil fromDate:[NSDate date] withCompa:nil];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    [[LocationManager sharedLocationManager] locationSetup];
    [[LocationManager sharedLocationManager]getCurrentLocation];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.postArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PostViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"postCell" forIndexPath:indexPath];
    PostModel *currentPost=[self.postArray objectAtIndex:indexPath.row];
    cell.startLocationLabel.text=currentPost.startName;
    cell.endLocationLabel.text=currentPost.endName;
    cell.distanceLabel.text=[NSString stringWithFormat:@"%@ mi",currentPost.distance];
    FIRDatabaseReference *userRef= [[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"users"]child:currentPost.owner];
    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSURL *photoURL=[NSURL URLWithString:snapshot.value[@"photoURL"]];
        [cell.profileImageView sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed: @"profile-pictures"] options:SDWebImageProgressiveDownload];
    }];
    NSDateFormatter* dateFormatter =[[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    cell.dateLabel.text=[NSString stringWithFormat:@"Departure:%@",[dateFormatter stringFromDate:currentPost.date]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CarPoolDetailViewController *dvc=[self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
    PostModel *currentPost=[self.postArray objectAtIndex:indexPath.row];
    dvc.currentPost = currentPost;
    [self.navigationController pushViewController:dvc animated:YES];
}
-(void)loadAllPostsWithKeys:(NSArray *)keys fromDate:(NSDate *)date withCompa:(NSComparator) comparetor{
    [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:YES];
    NSDate *fromDate=[NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSMutableArray *keysShouldShow=[[NSMutableArray alloc]init];
    BOOL hasKeys=NO;
    if(date)
        fromDate=date;
    if(keys){
        keysShouldShow=[keys mutableCopy];
        hasKeys=YES;
    }
    if(!comparetor){
        comparetor =^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            PostModel *post1=(PostModel *)obj1;
            PostModel *post2=(PostModel *)obj2;
            if([post1.distance floatValue]>[post2.distance floatValue])
                return NSOrderedDescending;
            else if ([post1.distance floatValue]<[post2.distance floatValue])
                return NSOrderedAscending;
            else
                return NSOrderedSame;
        };
    }
    self.postArray=[[NSMutableArray alloc]init];
    [self.tableView reloadData];
    self.observerRef=[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"posts"];
    self.observerHandle = [self.observerRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:snapshot.value];
        PostModel *post=[PostModel postWithDictionary:dict];
        post.key=snapshot.key;
        NSString *currentUid = [[FIRAuth auth]currentUser].uid;
        if(!hasKeys&&![post.owner isEqualToString:currentUid])
            [keysShouldShow addObject:snapshot.key];
        [[FireBaseManager sharedFireBaseManager].geoFire getLocationForKey:snapshot.key withCallback:^(CLLocation *location, NSError *error) {
            if(error==nil){
                
                CLLocation *currentLoaction=[LocationManager sharedLocationManager].currentLocation;
                if(currentLoaction){
                    CLLocationDistance distance=[currentLoaction distanceFromLocation:location];
                    post.distance=[NSString stringWithFormat:@"%.1f",distance*0.00062];
                }
                else
                    post.distance=@"";
                NSUInteger newIndex=[self.postArray indexOfObject:post inSortedRange:NSMakeRange(0, [self.postArray count]) options:NSBinarySearchingInsertionIndex usingComparator:comparetor
                                     ];
                
                if([keysShouldShow containsObject:snapshot.key]){
                    if([post.date compare:fromDate]==NSOrderedDescending||[post.date compare:fromDate]==NSOrderedSame){
                        [self.postArray insertObject:post atIndex:newIndex];
                        NSIndexPath *newPath=[NSIndexPath indexPathForRow:newIndex inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationBottom];
                    }
                    else{
                        
                    }
                }
                else{
                    
                }
                
                
                
                
            }
            else{
                NSLog(@"Retrive Location Error%@",error);
            }
        }];
    }];
    [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:NO];
}
- (IBAction)cancelAction:(id)sender {
    NSError *error=nil;
    NSString * instanceIDLocation = [NSString stringWithFormat:@"users/%@/instanceID",[FIRAuth auth].currentUser.uid];
    FIRDatabaseReference *instanceRef = [[[FireBaseManager sharedFireBaseManager].databaseRef root]child:instanceIDLocation];
    [instanceRef removeValue];
    [LoginManager ggLogout];
    [LoginManager fbLogout];
    [[FIRAuth auth]signOut:&error];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sortPostByOptions:(NSInteger)options{
    if(options==SORT_BY_TIME){
        [self.postArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            PostModel *post1=(PostModel *)obj1;
            PostModel *post2=(PostModel *)obj2;
            return [post1.date compare:post2.date];
        }];
        
    }
    if(options==SORT_BY_DISTANCE){
        [self.postArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            PostModel *post1=(PostModel *)obj1;
            PostModel *post2=(PostModel *)obj2;
            if([post1.distance floatValue]>[post2.distance floatValue])
                return NSOrderedDescending;
            else if ([post1.distance floatValue]<[post2.distance floatValue])
                return NSOrderedAscending;
            else
                return NSOrderedSame;
        }];
    }
}
-(NSComparator)comparatorByOptions:(NSInteger)options{
    NSComparator comparator =^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        PostModel *post1=(PostModel *)obj1;
        PostModel *post2=(PostModel *)obj2;
        return [post1.date compare:post2.date];
    };
    if(options==SORT_BY_TIME){
        NSComparator comparator =^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            PostModel *post1=(PostModel *)obj1;
            PostModel *post2=(PostModel *)obj2;
            return [post1.date compare:post2.date];
        };
        return comparator;
        
    }
    if(options==SORT_BY_DISTANCE){
        NSComparator comparator =^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            PostModel *post1=(PostModel *)obj1;
            PostModel *post2=(PostModel *)obj2;
            if([post1.distance floatValue]>[post2.distance floatValue])
                return NSOrderedDescending;
            else if ([post1.distance floatValue]<[post2.distance floatValue])
                return NSOrderedAscending;
            else
                return NSOrderedSame;
        };
        return comparator;
    }
    return comparator;
}
-(void)loadMyPosts{
    UserModel *user =[FireBaseManager sharedFireBaseManager].currentUser;
    FIRDatabaseReference *userRef = [[FireBaseManager sharedFireBaseManager]getUserRef:user.uid];
    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        UserModel *user = [UserModel userWithDict:snapshot.value];
        NSMutableArray *keys = [[NSMutableArray alloc]init];
        if(user.posts){
            for(NSString *postKey in user.posts){
                [keys addObject:postKey];
            }
        }
        [self loadAllPostsWithKeys:keys fromDate:nil withCompa:[self comparatorByOptions:-1]];
    }];
}
- (IBAction)segentAction:(UISegmentedControl *)sender {
    NSComparator comparator;
    switch (sender.selectedSegmentIndex) {
        case 0:
            //sort by distance
            [self.observerRef removeObserverWithHandle:self.observerHandle];
            comparator = [self comparatorByOptions:SORT_BY_DISTANCE];
            [self loadAllPostsWithKeys:nil fromDate:[NSDate date] withCompa:comparator];
            [self.tableView reloadData];
            break;
        case 1:
            [self.observerRef removeObserverWithHandle:self.observerHandle];
            comparator = [self comparatorByOptions:SORT_BY_TIME];
            [self loadAllPostsWithKeys:nil fromDate:[NSDate date] withCompa:comparator];
            [self.tableView reloadData];
            //sort by departure time
            break;
        case 2:
            [self.observerRef removeObserverWithHandle:self.observerHandle];
            [self loadMyPosts];
            break;
        default:
            break;
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
