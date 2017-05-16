//
//  LocationManager.h
//  CarPool
//
//  Created by Nathan Chen on 4/29/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
@import MapKit;
@interface LocationManager : NSObject<CLLocationManagerDelegate>
@property(strong,nonatomic) CLLocationManager *locationManager;
@property(strong,nonatomic) CLLocation *currentLocation;
-(void)getCurrentLocation;
+(instancetype)sharedLocationManager;
-(void)locationSetup;
@end
