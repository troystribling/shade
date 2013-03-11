//
//  CameraFactory.m
//  photio
//
//  Created by Troy Stribling on 6/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "CameraFactory.h"
#import "FilteredCameraViewController.h"
#import "InstantCameraFilter.h"
#import "BoxCameraFilter.h"
#import "PlasticCameraFilter.h"
#import "PassThoughFilter.h"

/////////////////////////////////////////////////////////////////////////////////////////
static CameraFactory* thisCameraFactory = nil;

/////////////////////////////////////////////////////////////////////////////////////////
@interface CameraFactory ()

- (void)setCamera:(Camera*)__camera forView:(GPUImageView*)__imageView;
- (void)setCameraFilter:(GPUImageOutput<GPUImageInput>*)__filter forView:(GPUImageView*)__imageView;
- (CGFloat)scaledFilterValue:(NSNumber*)__value;
- (CameraFilter*)cameraFilter;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@implementation CameraFactory

#pragma mark -
#pragma mark CameraFactory Private API

- (void)setCamera:(Camera*)__camera forView:(GPUImageView*)__imageView {
    self.camera = __camera;
    CameraFilter *camerFilter = [self cameraFilter];
    [self setCameraFilter:camerFilter.filter forView:__imageView];
    [self setCameraParameterValue:self.camera.value];
}

- (void)setCameraFilter:(GPUImageOutput<GPUImageInput>*)__filter forView:(GPUImageView*)__imageView {
    if (self.stillCamera) {
        [self.stillCamera stopCameraCapture];
        [self.stillCamera removeAllTargets];
        [__filter removeAllTargets];
    }
    self.stillCamera = [[GPUImageStillCamera alloc] init];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [__filter prepareForImageCapture];    
    [self.stillCamera addTarget:__filter];
    [__filter addTarget:__imageView];
    [self.stillCamera startCameraCapture];

}

- (CGFloat)scaledFilterValue:(NSNumber*)_value {
    CGFloat parameterRange = [self.camera.maximumValue floatValue] - [self.camera.minimumValue floatValue];
    return [_value floatValue ] / parameterRange;
}

- (CameraFilter*)cameraFilter {
    return [self.cameraFilters objectAtIndex:self.cameraId];
}

#pragma mark -
#pragma mark CameraFactory

+ (CameraFactory*)instance {
    @synchronized(self) {
        if (thisCameraFactory == nil) {
            thisCameraFactory = [[self alloc] init];
        }
    }
    return thisCameraFactory;
}

- (id)init {
    self = [super init];
    if (self) {
        self.loadedCameras = [Camera loadCameras];
        self.cameraFilters = @[[[PassThoughFilter alloc] init], [[InstantCameraFilter alloc] init], [[BoxCameraFilter alloc] init], [[PlasticCameraFilter alloc] init]];
    }
    return self;
}

- (void)setCameraWithId:(CameraId)__cameraId forView:(GPUImageView*)__imageView {
    self.cameraId = __cameraId;
    Camera *camera = [self.loadedCameras objectAtIndex:__cameraId];
    [self setCamera:camera forView:__imageView];
}

- (void)setCameraParameterValue:(NSNumber*)__value {
    self.camera.value = __value;
    [self.camera save];
    CameraFilter *cameraFilter = [self cameraFilter];
    [cameraFilter setParameterValue:__value];
}

- (void)captureStillImage:(void(^)(NSData* imageData, NSError* error))__completionHandler {
    CameraFilter *camerFilter = [self cameraFilter];
    [self.stillCamera capturePhotoAsPNGProcessedUpToFilter:camerFilter.filter withCompletionHandler:__completionHandler];
}

- (Camera*)defaultCamera {
    return [self.loadedCameras objectAtIndex:[self defaultCameraId]];
}

- (CameraId)defaultCameraId {
    return CameraIdBox;
}

- (BOOL)setLeftCameraForView:(GPUImageView*)__imageView {
    BOOL didSetCamera = NO;
    if (self.cameraId > 0) {
        didSetCamera = YES;
        [self setCameraWithId:(self.cameraId - 1) forView:__imageView];
    }
    return didSetCamera;
}

- (BOOL)setRightCameraForView:(GPUImageView*)__imageView {
    BOOL didSetCamera = NO;
    if (self.cameraId < ([self.loadedCameras count] - 1)) {
        didSetCamera = YES;
        [self setCameraWithId:(self.cameraId + 1) forView:__imageView];
    }
    return didSetCamera;
}

- (NSArray*)cameras {
    return self.loadedCameras;
}

@end
