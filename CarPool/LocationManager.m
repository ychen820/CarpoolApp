//
//  LocationManager.m
//  CarPool
//
//  Created by Nathan Chen on 4/29/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager
+(instancetype)sharedLocationManager{
    static dispatch_once_t sharedFireBaseToken;
    static LocationManager *sharedLocationManger=nil;
    dispatch_once(&sharedFireBaseToken, ^{
        sharedLocationManger=[[LocationManager alloc]init];
    });
    return sharedLocationManger;
}
-(void)locationSetup{
    self.locationManager=[[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    self.locationManager.delegate=self;
    [self.locationManager requestWhenInUseAuthorization];
}
-(void)getCurrentLocation{
    
    [self.locationManager startUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location=[locations lastObject];
    if(location !=nil){
        self.currentLocation=location;
        [self.locationManager stopUpdatingLocation];
    }
}
@end
