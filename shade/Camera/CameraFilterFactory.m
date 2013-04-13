//
//  CameraFilterFactory.m
//  photio
//
//  Created by Troy Stribling on 6/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "CameraFilterFactory.h"
#import "FilteredCameraViewController.h"
#import "InstantCameraFilter.h"
#import "BoxCameraFilter.h"
#import "PlasticCameraFilter.h"
#import "NativeCameraFilter.h"
#import "Camera+Extensions.h"

/////////////////////////////////////////////////////////////////////////////////////////
static CameraFilterFactory* thisFilterFactory = nil;

/////////////////////////////////////////////////////////////////////////////////////////
@interface CameraFilterFactory ()

- (GPUImageStillCamera*)stillCameraForCameraId:(CameraId)__cameraId;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@implementation CameraFilterFactory

#pragma mark -
#pragma mark CameraFilterFactory Private API

- (GPUImageStillCamera*)stillCameraForCameraId:(CameraId)__cameraId {
    return [self.stillCameras objectForKey:[NSNumber numberWithInt:__cameraId]];
}

#pragma mark -
#pragma mark CameraFilterFactory

+ (CameraFilterFactory*)instance {
    @synchronized(self) {
        if (thisFilterFactory == nil) {
            thisFilterFactory = [[self alloc] init];
        }
    }
    return thisFilterFactory;
}

- (id)init {
    self = [super init];
    if (self) {
        self.loadedCameras = [Camera loadCameras];
        self.stillCameras = [NSMutableDictionary dictionary];
        self.cameraFilters = @[[[NativeCameraFilter alloc] init], [[InstantCameraFilter alloc] init], [[BoxCameraFilter alloc] init], [[PlasticCameraFilter alloc] init]];
    }
    return self;
}

- (void)activateFilterWithCameraId:(CameraId)__cameraId forView:(GPUImageView*)__imageView {
    Camera *camera = [self.loadedCameras objectAtIndex:__cameraId];
    CameraFilter *cameraFilter = [self.cameraFilters objectAtIndex:__cameraId];
    GPUImageStillCamera *stillCamera = [[GPUImageStillCamera alloc] init];
    [self.stillCameras setObject:stillCamera forKey:[NSNumber numberWithInt:__cameraId]];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    [cameraFilter.filter prepareForImageCapture];
    [stillCamera addTarget:cameraFilter.filter];
    [cameraFilter.filter addTarget:__imageView];
    [self setParameterValue:camera.value forFilterWithCameraId:__cameraId];
}

- (void)deactivateFilterWithCameraId:(CameraId)__cameraId {
    GPUImageStillCamera *stillCamera = [self stillCameraForCameraId:__cameraId];
    CameraFilter *cameraFilter = [self.cameraFilters objectAtIndex:__cameraId];
    if (stillCamera) {
        [stillCamera stopCameraCapture];
        [stillCamera removeAllTargets];
        [cameraFilter.filter removeAllTargets];
        [self.stillCameras removeObjectForKey:[NSNumber numberWithInt:__cameraId]];
    }
}

- (void)startFilterWithCameraId:(CameraId)__cameraId {
    GPUImageStillCamera *stillCamera = [self stillCameraForCameraId:__cameraId];
    [stillCamera startCameraCapture];
}

- (void)stopFilterWithCameraId:(CameraId)__cameraId {
    GPUImageStillCamera *stillCamera = [self stillCameraForCameraId:__cameraId];
    [stillCamera stopCameraCapture];
}

- (void)captureStillImageForFilterWithCameraId:(CameraId)__cameraId onCompletion:(void(^)(NSData* imageData, NSError* error))__completionHandler {
    CameraFilter *camerFilter = [self.cameraFilters objectAtIndex:__cameraId];
    GPUImageStillCamera *stillCamera = [self stillCameraForCameraId:__cameraId];
    [stillCamera capturePhotoAsJPEGProcessedUpToFilter:camerFilter.filter withCompletionHandler:__completionHandler];
}

- (void)rotateFilterCameraWithCameraId:(CameraId)__cameraId {
    GPUImageStillCamera *stillCamera = [self stillCameraForCameraId:__cameraId];
    if (stillCamera) {
        [stillCamera rotateCamera];
    }
}

#pragma mark -

- (void)activateFilterWithCameraId:(CameraId)__cameraId forView:(GPUImageView *)__imageView withImage:(UIImage*)__image {
    Camera *camera = [self.loadedCameras objectAtIndex:__cameraId];
    CameraFilter *cameraFilter = [self.cameraFilters objectAtIndex:__cameraId];
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:__image smoothlyScaleOutput:YES];
    [self.imagePictures setObject:imagePicture forKey:[NSNumber numberWithInt:__cameraId]];
    [cameraFilter.filter forceProcessingAtSize:__imageView.sizeInPixels];
    [imagePicture addTarget:cameraFilter.filter];
    [cameraFilter.filter addTarget:__imageView];
    [imagePicture processImage];
    [self setParameterValue:camera.value forFilterWithCameraId:__cameraId];
}

#pragma mark -

- (void)setParameterValue:(NSNumber*)__value forFilterWithCameraId:(CameraId)__cameraId  {
    CameraFilter *cameraFilter = [self.cameraFilters objectAtIndex:__cameraId];
    [cameraFilter setParameterValue:__value];
}

- (CameraId)defaultCameraId {
    return CameraIdIPhone;
}

- (NSArray*)cameraIds {
    NSMutableArray *cameraIds = [NSMutableArray array];
    for (Camera *camera in [self loadedCameras]) {
        [cameraIds addObject:camera.identifier];
    }
    return cameraIds;
}

- (CameraId)nextRightCameraIdRelativeTo:(CameraId)__cameraId {
    CameraId nextId = __cameraId - 1;
    if (__cameraId == 0) {
        nextId = [self.loadedCameras count] - 1;
    }
    return nextId;
}

- (CameraId)nextLeftCameraIdRelativeTo:(CameraId)__cameraId {
    CameraId nextId = __cameraId + 1;
    if (nextId > [self.loadedCameras count] - 1) {
        nextId = 0;
    }
    return nextId;
}

@end
