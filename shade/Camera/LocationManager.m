//
//  LocationManager.m
//  photio
//
//  Created by Troy Stribling on 6/22/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "LocationManager.h"

#define LOCATION_MANAGER_ACCURACY               10.0f
#define LOCATION_MANAGER_DISTANCE_FILTER        20.0f
#define DEFAULT_LATITUDE                        38.9143
#define DEFAULT_LONGITUDE                       -77.038f

/////////////////////////////////////////////////////////////////////////////////////////
static LocationManager* thisLocationManager;

/////////////////////////////////////////////////////////////////////////////////////////
@interface LocationManager (PrivateAPI)

@end

/////////////////////////////////////////////////////////////////////////////////////////
@implementation LocationManager

@synthesize locationManager = _locationManager;
@synthesize isRunning;

#pragma mark - 
#pragma mark LocationManager Private

#pragma mark - 
#pragma mark LocationManager

+ (LocationManager*)instance {
    @synchronized(self) {
        if (thisLocationManager == nil) {
            thisLocationManager = [[self alloc] init];
        }
    }
    return thisLocationManager;
}

- (id)init {
    if (self = [super init]) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = LOCATION_MANAGER_ACCURACY;
        self.locationManager.distanceFilter = LOCATION_MANAGER_DISTANCE_FILTER;
        self.isRunning = NO;
        [self start];
    }
    return self;
}

- (CLLocationManager*)locationManager {
    if (_locationManager != nil) {
		return _locationManager;
	}	
	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[_locationManager setDelegate:self];	
	return _locationManager;
}

- (CLLocation*)location {
    if (self.isRunning) {
        return [self.locationManager location];
    } else {
        return [[CLLocation alloc] initWithLatitude:DEFAULT_LATITUDE longitude:DEFAULT_LONGITUDE];
    }
}

- (void)start {
    if (!self.isRunning && [CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        self.isRunning = YES;
    }
}

- (void)stop {
    if (self.isRunning) {
        [self.locationManager stopUpdatingLocation];
        self.isRunning = NO;
    }
}

#pragma mark - 
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation {
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

@end
