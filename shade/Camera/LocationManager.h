//
//  LocationManager.h
//  photio
//
//  Created by Troy Stribling on 6/22/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager*     locationManager;
@property(nonatomic, assign) BOOL                   isRunning;

+ (LocationManager*)instance;
- (CLLocation*)location;
- (void)start;
- (void)stop;

@end
