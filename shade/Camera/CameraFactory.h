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

@property(nonatomic, strong) NSArray                            *loadedCameras;
@property(nonatomic, strong) NSArray                            *cameraFilters;
@property(nonatomic, strong) GPUImageStillCamera                *stillCamera;
@property(nonatomic, strong) Camera                             *camera;
@property(nonatomic, assign) CameraId                           cameraId;

+ (CameraFactory*)instance;
- (void)setCameraWithId:(CameraId)__cameraId forView:(GPUImageView*)__imageView;
- (void)setCameraParameterValue:(NSNumber*)__value;
- (void)captureStillImage:(void(^)(NSData* imageData, NSError* error))__completionHandler;
- (Camera*)defaultCamera;
- (CameraId)defaultCameraId;
- (BOOL)setLeftCameraForView:(GPUImageView*)__imageView;
- (BOOL)setRightCameraForView:(GPUImageView*)__imageView;
- (NSArray*)cameras;

@end
