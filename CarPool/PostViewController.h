//
//  PostViewController.h
//  CarPool
//
//  Created by Nathan Chen on 4/29/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;
@interface PostViewController : UIViewController
@property(strong,nonatomic) CLLocation *startLocation;
@property(strong,nonatomic) CLLocation *endLocation;
@property (weak, nonatomic) IBOutlet UITextField *startLocationField;
@property (weak, nonatomic) IBOutlet UITextField *destinationField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextfield;
@property (weak, nonatomic) IBOutlet UITextField *carModelField;
@property(assign,nonatomic) BOOL clearButtonTouched;
@property(strong,nonatomic) NSDate *pickUpDate;
@property(strong,nonatomic) NSArray *inputArray;
-(BOOL)checkEmpty;
@end
