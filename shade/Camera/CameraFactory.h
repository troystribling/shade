//
//  CameraFactory.h
//  photio
//
//  Created by Troy Stribling on 6/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@class Camera;
@class CameraFilter;
@class FilteredCameraViewController;

@interface CameraFactory : NSObject

@property(nonatomic, strong) NSArray                            *loadedCameras;
@property(nonatomic, strong) NSArray                            *cameraFilters;
@property(nonatomic, strong) Camera                             *camera;
@property(nonatomic, strong) GPUImageStillCamera                *stillCamera;

+ (CameraFactory*)instance;
- (void)setCamera:(Camera*)__camera forView:(GPUImageView*)__imageView;
- (void)setCameraParameterValue:(NSNumber*)__value;
- (void)captureStillImage:(void(^)(NSData* imageData, NSError* error))__completionHandler;
- (Camera*)defaultCamera;
- (NSArray*)cameras;

@end
