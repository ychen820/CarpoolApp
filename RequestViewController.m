//
//  RequestViewController.m
//  CarPool
//
//  Created by Nathan Chen on 5/2/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "RequestViewController.h"
#import "GeoFire.h"
#import "FireBaseManager.h"
#import "CarpoolTableViewController.h"
@interface RequestViewController ()
@property(strong,nonatomic) GeoFire *geoFire;
@property(assign) FIRDatabaseHandle geoQueryHandle;
@property(strong,nonatomic) NSMutableArray *queryResult;
@end

@implementation RequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self geoFireSetup];
    // Do any additional setup after loading the view.
}
-(void)geoFireSetup{
    FIRDatabaseReference *startLocationRef=[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"startLocations"];
    self.geoFire=[[GeoFire alloc]initWithFirebaseRef:startLocationRef];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)searchAction:(id)sender {
    self.queryResult=[[NSMutableArray alloc]init];
    CarpoolTableViewController *ctvc=(CarpoolTableViewController *)[self.navigationController.viewControllers objectAtIndex:0];
    if(![self checkEmpty]){
        if(self.startLocation){
            GFCircleQuery *query=[self.geoFire queryAtLocation:self.startLocation withRadius:SEARCH_RADIUS];
            self.geoQueryHandle=[query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
                [self.queryResult addObject:key];
            }];
            [query observeReadyWithBlock:^{
                [ctvc loadAllPostsWithKeys:self.queryResult fromDate:self.pickUpDate withCompa:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
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
