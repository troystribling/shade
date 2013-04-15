//
//  CameraFilterFactory.h
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

@interface CameraFilterFactory : NSObject

@property(nonatomic, strong) NSArray                *loadedCameras;
@property(nonatomic, strong) NSArray                *cameraFilters;
@property(nonatomic, strong) NSMutableDictionary    *stillCameras;
@property(nonatomic, strong) NSMutableDictionary    *imagePictures;

+ (CameraFilterFactory*)instance;

- (void)activateCameraFilterWithCameraId:(CameraId)__cameraId forView:(GPUImageView*)__imageView;
- (void)deactivateCameraFilterWithCameraId:(CameraId)__cameraId;

- (void)startFilterWithCameraId:(CameraId)__cameraId;
- (void)stopFilterWithCameraId:(CameraId)__cameraId;
- (void)captureStillImageForFilterWithCameraId:(CameraId)__cameraId onCompletion:(void(^)(NSData* imageData, NSError* error))__completionHandler;
- (void)rotateFilterCameraWithCameraId:(CameraId)__cameraId;

- (void)activatePictureFilterWithCameraId:(CameraId)__cameraId forView:(GPUImageView *)__imageView withImage:(UIImage*)__image;
- (void)deactivatePictureFilterWithCameraId:(CameraId)__cameraId;

- (void)setParameterValue:(NSNumber*)__value forFilterWithCameraId:(CameraId)__cameraId;

- (CameraId)defaultCameraId;
- (NSArray*)cameraIds;
- (CameraId)nextRightCameraIdRelativeTo:(CameraId)__cameraId;
- (CameraId)nextLeftCameraIdRelativeTo:(CameraId)__cameraId;

@end
