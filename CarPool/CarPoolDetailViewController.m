//
//  CarPoolDetailViewController.m
//  CarPool
//
//  Created by Nathan Chen on 5/3/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//
#import "GeoFire.h"
#import "CarPoolDetailViewController.h"
#import "FireBaseManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "ChatViewController.h"
@interface CarPoolDetailViewController ()<MKMapViewDelegate>
@property (strong, nonatomic) FIRDatabaseReference *currentPostRequestRef;
// ReqestButton: Requested, Request

@property (assign) NSUInteger requestStatus;
@end

@implementation CarPoolDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate=self;
    [self displayDetailInformation];
        [self getLocationFromPost];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2;
    [self.profileImageView.layer setMasksToBounds:YES];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
}
-(void)dealloc{
    self.mapView=nil;
    self.currentPost=nil;
 
}

- (IBAction)requestButton:(id)sender {
    
    NSString *instanceToken = self.currentPostUser.instanceID;
     NSString *message =[NSString stringWithFormat:@"%@ sent you a ride request",[FireBaseManager sharedFireBaseManager].currentUser.firstName];
    if(instanceToken){
        NSDictionary *riderInfo = @{@"postKey":self.currentPost.key,@"requestUserId":[FIRAuth auth].currentUser.uid};
       
        NSDictionary *notificationDict = @{
                                           @"username": instanceToken,
                                           @"message" : message ,
                                           @"rideinfo" :riderInfo
                                           ,@"type":@"request"
                                           };
        
        [[[[[FireBaseManager sharedFireBaseManager].databaseRef root] child:@"notificationRequests"]childByAutoId] updateChildValues:notificationDict];
        
    }
    
    FIRDatabaseReference *userRequestRef = [[[FireBaseManager sharedFireBaseManager]getRequestsUnderUserRefForUser:self.currentPostUser.uid withPostKey:self.currentPost.key]child:[FIRAuth auth].currentUser.uid];
    [userRequestRef setValue:message];
    NSDictionary *requestValue=@{@"status":@"requested"};
    [self.currentPostRequestRef setValue:requestValue];
    [self checkRequestStatus];
}

-(void)getLocationFromPost{
    __block CLLocation *startLocation;
    __block CLLocation *endLocation;
    FIRDatabaseReference *startLocationRef=[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"startLocations"];
    __block GeoFire *geofire=[[FireBaseManager sharedFireBaseManager].geoFire initWithFirebaseRef:startLocationRef];
    
    [geofire getLocationForKey:self.currentPost.key withCallback:^(CLLocation *location, NSError *error) {
        startLocation=location;
        FIRDatabaseReference *endLocationRef=[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"endLocations"];
        geofire=[geofire initWithFirebaseRef:endLocationRef];
        [geofire getLocationForKey:self.currentPost.key withCallback:^(CLLocation *location, NSError *error) {
            endLocation=location;
            [self createRouteWithLocations:startLocation endLocation:endLocation];
        }];
    }];
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer=[[MKPolylineRenderer alloc]initWithOverlay:overlay];
    renderer.strokeColor=[UIColor blueColor];
    renderer.lineWidth=3.0;
    [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:NO];
    return renderer;
    
}
- (IBAction)startChatAction:(UIButton *)sender {
    ChatViewController *cvc = [[ChatViewController alloc]init];
    cvc.senderId = [FIRAuth auth].currentUser.uid;
    cvc.senderDisplayName = [FIRAuth auth].currentUser.uid;
    
    cvc.recipient = self.currentPostUser;
    [self.navigationController pushViewController:cvc animated:YES];
    
}
-(void)createRouteWithLocations:(CLLocation*)startLocation endLocation:(CLLocation *)endLocation{
    [(AppDelegate *)[UIApplication sharedApplication].delegate setNetworkIndication:YES];
    MKPlacemark *startPlacemark=[[MKPlacemark alloc]initWithCoordinate:startLocation.coordinate];
    MKPlacemark *endPlacemark=[[MKPlacemark alloc]initWithCoordinate:endLocation.coordinate];
    MKMapItem *startItem=[[MKMapItem alloc]initWithPlacemark:startPlacemark];
    MKMapItem *endItem=[[MKMapItem alloc]initWithPlacemark:endPlacemark];
    MKPointAnnotation *startPoint=[MKPointAnnotation alloc];
    MKPointAnnotation *endPoint=[MKPointAnnotation alloc];
    startPoint.title=self.currentPost.startName;
    startPoint.coordinate=startLocation.coordinate;
    endPoint.coordinate=endLocation.coordinate;
    endPoint.title=self.currentPost.endName;
    
    [self.mapView showAnnotations:@[startPoint,endPoint] animated:YES];
    MKDirectionsRequest *request=[[MKDirectionsRequest alloc]init];
    request.source=startItem;
    request.destination=endItem;
    request.transportType=MKDirectionsTransportTypeAutomobile;
    MKDirections *direction=[[MKDirections alloc]initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if(error==nil){
            MKRoute *route=response.routes[0];
            
            [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
            MKMapRect routeRect=route.polyline.boundingMapRect;
            MKCoordinateRegion region=MKCoordinateRegionForMapRect(routeRect);
            region.span.latitudeDelta*=1.1;
            region.span.longitudeDelta*=1.1;
            [self.mapView setRegion:region animated:NO];
        }
        else{
            NSLog(@"Route Error:%@",error.description);
        }
        
    }];
}
-(void)displayDetailInformation{
    FIRDatabaseReference *userRef= [[[[FireBaseManager sharedFireBaseManager].databaseRef root]child:@"users"]child:self.currentPost.owner];
    [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.currentPostUser = [UserModel userWithDict:snapshot.value];
        self.currentPostUser.uid = snapshot.key;
        NSURL *photoURL = [NSURL URLWithString:self.currentPostUser.photoURL];
        [self.profileImageView sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed: @"profile-pictures"] options:SDWebImageProgressiveDownload];
        self.nameLabel.text=[NSString stringWithFormat:@"Driver Name: %@ %@",snapshot.value[@"firstName"],snapshot.value[@"lastName"]];
        self.ageLabel.text=[NSString stringWithFormat:@"Age: %@",snapshot.value[@"age"]];
        self.currentPostRequestRef = [[[[[[FireBaseManager sharedFireBaseManager].databaseRef root] child:@"posts"]child:self.currentPost.key]child:@"requests"]child:[FIRAuth auth].currentUser.uid];
        self.startLocationLabel.text=[NSString stringWithFormat:@"From: %@",self.currentPost.startName];
        self.endLocationLabel.text=[NSString stringWithFormat:@"To: %@",self.currentPost.endName];
        self.carModelLabel.text = [NSString stringWithFormat:@"Car Model: %@",self.currentPost.carModel];
        if([self.currentPost.owner isEqualToString:[FIRAuth auth].currentUser.uid]){
            [self.requestButton setAlpha:0];
            [self.requestButton setUserInteractionEnabled:NO];
            [self.endTripButton setHidden:NO];
            
        }
            
        NSDateFormatter* dateFormatter =[[NSDateFormatter alloc]init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        self.departureTimeLabel.text=[NSString stringWithFormat:@"Departure: %@",[dateFormatter stringFromDate:self.currentPost.date]];
        [self checkRequestStatus];
    }];
    
}
-(void)checkRequestStatus{
    [self.currentPostRequestRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(![snapshot hasChildren]){

            self.requestStatus=CURRENT_POST_NOTREQUESTED;
        }
        else{
            if([snapshot.value[@"status"] isEqualToString:@"accepted"])
                self.requestStatus=CURRENT_POST_ACCEPTED;
            else if([snapshot.value[@"status"] isEqualToString:@"requested"]||[snapshot.value[@"status"] isEqualToString:@"declined"])
                self.requestStatus = CURRENT_POST_REQUESTED;
            
        }
        [self setButtonState];
    }];
}
-(void)setButtonState{
    switch (self.requestStatus) {
        case CURRENT_POST_NOTREQUESTED:
            self.chatButton.enabled = NO;
            self.requestButton.enabled = YES;
            break;
        case CURRENT_POST_REQUESTED:
            self.chatButton.enabled = NO;
            [self.requestButton setTitle:@"Request Sent" forState:UIControlStateDisabled];
            self.requestButton.enabled = NO;
            
            break;
        case CURRENT_POST_ACCEPTED:
            self.chatButton.enabled = YES;
            [self.requestButton setTitle:@"Request Accepted" forState:UIControlStateDisabled];
            self.requestButton.enabled = NO;
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
