//
//  CameraFactory.h
//  photio
//
//  Created by Troy Stribling on 6/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "Camera.h"

@class Camera;
@class FilteredCameraViewController;

typedef enum {
    CameraTypeIPhone,
    CameraTypeInstant,
    CameraTypePixel,
    CameraTypeBox,
    CameraTypePlastic
} CameraType;

@interface CameraFactory : NSObject

@property(nonatomic, strong) NSArray*                           loadedCameras;
@property(nonatomic, strong) NSDictionary*                      loadedCameraParameters;
@property(nonatomic, strong) Camera*                            camera;
@property(nonatomic, strong) GPUImageStillCamera*               stillCamera;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput>*     filter;

+ (CameraFactory*)instance;
- (void)setCamera:(Camera*)_camera forView:(GPUImageView*)_imageView;
- (void)setCameraParmeterValue:(NSNumber*)_value;
- (void)captureStillImage:(void(^)(NSData* imageData, NSError* error))_completionHandler;
- (Camera*)defaultCamera;
- (NSArray*)cameras;

- (GPUImageOutput<GPUImageInput>*)filterInstantCamera;
- (GPUImageOutput<GPUImageInput>*)filterPixelCamera;
- (GPUImageOutput<GPUImageInput>*)filterBoxCamera;
- (GPUImageOutput<GPUImageInput>*)filterPlasticCamera;

- (void)setInstantCameraParameterValue:(NSNumber*)_value forFilter:(GPUImageOutput<GPUImageInput>*)_filter;
- (void)setPixelCameraParameterValue:(NSNumber*)_value forFilter:(GPUImageOutput<GPUImageInput>*)_filter;
- (void)setBoxCameraParameterValue:(NSNumber*)_value forFilter:(GPUImageOutput<GPUImageInput>*)_filter;
- (void)setPlasticCameraParameterValue:(NSNumber*)_value forFilter:(GPUImageOutput<GPUImageInput>*)_filter;

@end
