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
- (void)setCamera:(Camera*)__camera forView:(GPUImageView*)__imageView;
- (void)setCameraParmeterValue:(NSNumber*)__value;
- (void)captureStillImage:(void(^)(NSData* imageData, NSError* error))__completionHandler;
- (Camera*)defaultCamera;
- (NSArray*)cameras;

- (GPUImageOutput<GPUImageInput>*)filterInstantCamera;
- (GPUImageOutput<GPUImageInput>*)filterPixelCamera;
- (GPUImageOutput<GPUImageInput>*)filterBoxCamera;
- (GPUImageOutput<GPUImageInput>*)filterPlasticCamera;

- (void)setInstantCameraParameterValue:(NSNumber*)__value forFilter:(GPUImageOutput<GPUImageInput>*)__filter;
- (void)setBoxCameraParameterValue:(NSNumber*)__value forFilter:(GPUImageOutput<GPUImageInput>*)__filter;
- (void)setPlasticCameraParameterValue:(NSNumber*)__value forFilter:(GPUImageOutput<GPUImageInput>*)__filter;

@end
