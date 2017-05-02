//
//  LocationController.h
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/2/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@interface LocationController : NSObject

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(strong, nonatomic) CLLocation *location;
@property(weak, nonatomic) id delegate;

@end
