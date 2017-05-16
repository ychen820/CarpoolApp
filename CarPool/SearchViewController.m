//
//  SearchViewController.m
//  CarPool
//
//  Created by Nathan Chen on 4/29/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "SearchViewController.h"
#import "LocationManager.h"
#import "AppDelegate.h"
@interface SearchViewController ()<UISearchBarDelegate,UISearchControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchTabelView;
@property(strong,nonatomic)UISearchController *searchController;
@property(strong,nonatomic)UISearchBar *searchBar;
@property(strong,nonatomic)NSArray *searchResult;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self searchBarSetup];
    self.searchTabelView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];;

    [[LocationManager sharedLocationManager] locationSetup];
    [[LocationManager sharedLocationManager]getCurrentLocation];
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
  
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
      [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:YES];
    CLLocation *currentLoaction=[LocationManager sharedLocationManager].currentLocation;
    MKLocalSearchRequest *request=[[MKLocalSearchRequest alloc]init];
    request.naturalLanguageQuery=self.searchBar.text;
 
    MKCoordinateRegion region=MKCoordinateRegionMake(currentLoaction.coordinate,MKCoordinateSpanMake(1, 1));
    request.region=region;
    MKLocalSearch *search=[[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
          [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:NO];
        if(error==nil){
        self.searchResult=response.mapItems;
            [self.searchTabelView reloadData];
        }
        else{
            NSLog(@"mapSearchError%@",error.description);
        }
    }];
}
-(void)searchBarSetup{
    self.searchController=[[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater=self;
    self.searchController.hidesNavigationBarDuringPresentation=NO;
    self.searchController.dimsBackgroundDuringPresentation=NO;
    self.searchController.definesPresentationContext=YES;
    self.searchBar=self.searchController.searchBar;
    self.searchBar.delegate = self;
    self.searchBar.text=self.textfield.text;
    self.navigationItem.titleView=self.searchBar;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --tableview delegates
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.searchResult count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    MKMapItem *item=(MKMapItem *)[self.searchResult objectAtIndex:indexPath.row];
    MKPlacemark *placemark=item.placemark;
    cell.textLabel.text=placemark.name;
    cell.detailTextLabel.text=[self parseAddress:placemark];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MKMapItem *item=(MKMapItem *)[self.searchResult objectAtIndex:indexPath.row];
    MKPlacemark *placemark=item.placemark;
    self.textfield.text=[self parseAddress:placemark];

    if(self.textfield.tag==0)
        self.pvc.startLocation=item.placemark.location;
    else if(self.textfield.tag==1)
        self.pvc.endLocation=item.placemark.location;
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(NSString *)parseAddress:(MKPlacemark *)selectedItem{
    NSString *firstSpace=(selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? @" ": @"";
    NSString *comma=(selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? @", " : @"";
    NSString *secondSpace=(selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? @" " : @"";
    NSString *address=[NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                       // street number
                       selectedItem.subThoroughfare?selectedItem.subThoroughfare:@"",
                       firstSpace,
                       // street name
                       selectedItem.thoroughfare?selectedItem.thoroughfare:@"",
                       comma,
                       // city
                       selectedItem.locality?selectedItem.locality:@"",
                       secondSpace,
                       // state
                       selectedItem.administrativeArea?selectedItem.administrativeArea:@""];
    return address;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self dismissViewControllerAnimated:YES completion:nil];
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
