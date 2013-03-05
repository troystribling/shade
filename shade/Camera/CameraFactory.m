//
//  CameraFactory.m
//  photio
//
//  Created by Troy Stribling on 6/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "CameraFactory.h"
#import "FilteredCameraViewController.h"
#import "Camera+Extensions.h"
#import "InstantCameraFilter.h"
#import "BoxCameraFilter.h"
#import "PlasticCameraFilter.h"
#import "PassThoughFilter.h"

/////////////////////////////////////////////////////////////////////////////////////////
static CameraFactory* thisCameraFactory = nil;

/////////////////////////////////////////////////////////////////////////////////////////
@interface CameraFactory ()

- (CGFloat)scaledFilterValue:(NSNumber*)__value;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@implementation CameraFactory

#pragma mark -
#pragma mark CameraFactory PrivayeApi

- (void)setCameraFilter:(GPUImageOutput<GPUImageInput>*)__filter forView:(GPUImageView*)__imageView {
    if (self.stillCamera) {
        [self.stillCamera stopCameraCapture];
        [self.stillCamera removeAllTargets];
        [self.filter removeAllTargets];
    }
    self.stillCamera = [[GPUImageStillCamera alloc] init];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.filter = __filter;
    [self.filter prepareForImageCapture];    
    [self.stillCamera addTarget:_filter];
    [self.filter addTarget:_imageView];  
    [self.stillCamera startCameraCapture];

}

- (void)captureStillImage:(void(^)(NSData* imageData, NSError* error))__completionHandler {
    [self.stillCamera capturePhotoAsJPEGProcessedUpToFilter:self.filter withCompletionHandler:__completionHandler];
}

- (CGFloat)scaledFilterValue:(NSNumber*)_value {
    CGFloat parameterRange = [self.camera.maximumValue floatValue] - [self.camera.minimumValue floatValue];
    return [_value floatValue ] / parameterRange;
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
        NSDictionary *parameters = [Camera loadCameraParameters];
        self.cameraFilters = @[[[PassThoughFilter alloc] init], [[InstantCameraFilter alloc] init], [[BoxCameraFilter alloc] init], [[PlasticCameraFilter alloc] init]];
    }
    self;
}

- (void)setCamera:(Camera*)__camera forView:(GPUImageView*)__imageView {
    self.camera = __camera;
    CameraFilter *camerFilter = [self.cameraFilters objectAtIndex:[self.camera.identifier intValue]];
    [self setCameraFilter:camerFilter.filter forView:__imageView];
    [self setCameraParmeterValue:self.camera.value];
}

- (void)setCameraParameterValue:(NSNumber*)__value {
    self.camera.value = __value;
    [self.camera save];
    CameraFilter *cameraFilter = [self.cameraFilters objectAtIndex:[self.camera.identifier intValue]];
    [cameraFilter setParameterValue:__value];
}

- (Camera*)defaultCamera {
    return [self.loadedCameras objectAtIndex:CameraTypeIPhone];
}

- (NSArray*)cameras {
    return self.loadedCameras;
}


@end
