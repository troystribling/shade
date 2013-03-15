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

- (void)activateStillCameraForCameraWithId:(CameraId)__cameraId forView:(GPUImageView*)__imageView;
- (GPUImageStillCamera*)stillCameraForCameraId:(CameraId)__cameraId;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@implementation CameraFactory

#pragma mark -
#pragma mark CameraFactory Private API

- (void)activateStillCameraForCameraWithId:(CameraId)__cameraId forView:(GPUImageView*)__imageView {
    CameraFilter *cameraFilter = [self.cameraFilters objectAtIndex:__cameraId];
    GPUImageStillCamera *stillCamera = [[GPUImageStillCamera alloc] init];
    [self.stillCameras setObject:stillCamera forKey:[NSNumber numberWithInt:__cameraId]];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [cameraFilter.filter prepareForImageCapture];
    [stillCamera addTarget:cameraFilter.filter];
    [cameraFilter.filter addTarget:__imageView];
    [stillCamera startCameraCapture];
}

- (GPUImageStillCamera*)stillCameraForCameraId:(CameraId)__cameraId {
    return [self.stillCameras objectForKey:[NSNumber numberWithInt:__cameraId]];
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
        self.stillCameras = [NSMutableDictionary dictionary];
        self.cameraFilters = @[[[PassThoughFilter alloc] init], [[InstantCameraFilter alloc] init], [[BoxCameraFilter alloc] init], [[PlasticCameraFilter alloc] init]];
    }
    return self;
}

- (void)activateCameraWithId:(CameraId)__cameraId forView:(GPUImageView*)__imageView {
    [self activateStillCameraForCameraWithId:__cameraId forView:__imageView];
    Camera *camera = [self.loadedCameras objectAtIndex:__cameraId];
    [self setParameterValue:camera.value forCameraWithId:__cameraId];
}

- (void)setParameterValue:(NSNumber*)__value forCameraWithId:(CameraId)__cameraId  {
    Camera *camera = [self.loadedCameras objectAtIndex:__cameraId];
    camera.value = __value;
    [camera save];
    CameraFilter *cameraFilter = [self.cameraFilters objectAtIndex:__cameraId];
    [cameraFilter setParameterValue:__value];
}

- (void)captureStillImageForCameraWithId:(CameraId)__cameraId onCompletion:(void(^)(NSData* imageData, NSError* error))__completionHandler {
    CameraFilter *camerFilter = [self.cameraFilters objectAtIndex:__cameraId];
    GPUImageStillCamera *stillCamera = [self stillCameraForCameraId:__cameraId];
    [stillCamera capturePhotoAsPNGProcessedUpToFilter:camerFilter.filter withCompletionHandler:__completionHandler];
}

- (void)deactivateStillCameraForCameraWithId:(CameraId)__cameraId {
    GPUImageStillCamera *stillCamera = [self stillCameraForCameraId:__cameraId];
    CameraFilter *cameraFilter = [self.cameraFilters objectAtIndex:__cameraId];
    if (stillCamera) {
        [stillCamera stopCameraCapture];
        [stillCamera removeAllTargets];
        [cameraFilter.filter removeAllTargets];
        [self.stillCameras removeObjectForKey:[NSNumber numberWithInt:__cameraId]];
    }
}

- (void)rotateCameraWithCameraId:(CameraId)__cameraId {
    GPUImageStillCamera *stillCamera = [self stillCameraForCameraId:__cameraId];
    if (stillCamera) {
        [stillCamera rotateCamera];
    }
}

- (CameraId)defaultCameraId {
    return CameraIdIPhone;
}

@end
