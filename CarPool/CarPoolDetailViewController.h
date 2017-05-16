//
//  CarPoolDetailViewController.h
//  CarPool
//
//  Created by Nathan Chen on 5/3/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//
#import "UserModel.h"
#import "PostModel.h"

typedef enum : NSUInteger {
    CURRENT_POST_REQUESTED,
    CURRENT_POST_NOTREQUESTED,
    CURRENT_POST_ACCEPTED,
} MyPostRequestStatus;
@import MapKit;
@interface CarPoolDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *requestButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLocationLabel;
@property(strong,nonatomic) PostModel *currentPost;
@property (weak, nonatomic) IBOutlet UILabel *departureTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *endTripButton;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property(strong,nonatomic) UserModel *currentPostUser;
@end
