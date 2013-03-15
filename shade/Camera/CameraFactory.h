//
//  CameraFactory.h
//  photio
//
//  Created by Troy Stribling on 6/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "Camera+Extensions.h"

@class Camera;
@class CameraFilter;
@class FilteredCameraViewController;

@interface CameraFactory : NSObject

@property(nonatomic, strong) NSArray                *loadedCameras;
@property(nonatomic, strong) NSArray                *cameraFilters;
@property(nonatomic, strong) NSMutableDictionary    *stillCameras;

+ (CameraFactory*)instance;
- (void)activateCameraWithId:(CameraId)__cameraId forView:(GPUImageView*)__imageView;
- (void)setParameterValue:(NSNumber*)__value forCameraWithId:(CameraId)__cameraId;
- (void)captureStillImageForCameraWithId:(CameraId)__cameraId onCompletion:(void(^)(NSData* imageData, NSError* error))__completionHandler;
- (void)deactivateStillCameraForCameraWithId:(CameraId)__cameraId;
- (void)rotateCameraWithCameraId:(CameraId)__cameraId;
- (CameraId)defaultCameraId;

@end
