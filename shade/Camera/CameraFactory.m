//
//  CameraFactory.m
//  photio
//
//  Created by Troy Stribling on 6/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "CameraFactory.h"
#import "FilteredCameraViewController.h"
#import "SaturationCameraFilter.h"
#import "DataContextManager.h"

/////////////////////////////////////////////////////////////////////////////////////////
static CameraFactory* thisCameraFactory = nil;

/////////////////////////////////////////////////////////////////////////////////////////
@interface CameraFactory ()

+ (NSArray*)loadCameras;
+ (NSDictionary*)loadCameraParameters;
- (CGFloat)scaledFilterValue:(NSNumber*)__value;
- (NSNumber*)increasingParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value;
- (NSNumber*)decreasingParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value;
- (NSNumber*)mirroredMaximumParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value;
- (NSNumber*)mirroredMinimumParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@interface CameraFactory (ParameterValues)

- (NSDictionary*)initialInstantCameraParameterValues;
- (NSDictionary*)initialBoxCameraParameterValues;
- (NSDictionary*)initialPlasticCameraParameterValues;

- (NSDictionary*)instantCameraParameterValues:(NSNumber*)__value;
- (NSDictionary*)boxCameraParameterValues:(NSNumber*)__value;
- (NSDictionary*)plasticCameraParameterValues:(NSNumber*)__value;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@interface CameraFactory (Cameras)

- (void)setIPhoneCamera:(GPUImageView*)__imageView;
- (void)setInstantCamera:(GPUImageView*)__imageView;
- (void)setBoxCamera:(GPUImageView*)__imageView;
- (void)setPlasticCamera:(GPUImageView*)__imageView;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@implementation CameraFactory

#pragma mark -
#pragma mark CameraFactory PrivayeApi

+ (NSArray*)loadCameras {
    DataContextManager* contextManager = [DataContextManager instance];
    
    NSString* cameraFile = [[NSBundle  mainBundle] pathForResource:@"Cameras" ofType:@"plist"];
    NSArray* configuredCameras = [[NSDictionary dictionaryWithContentsOfFile:cameraFile] objectForKey:@"cameras"];
    NSInteger configuredCameraCount = [configuredCameras count];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* cameraEntity = [NSEntityDescription entityForName:@"Camera" inManagedObjectContext:contextManager.mainObjectContext];
    [fetchRequest setEntity:cameraEntity];   
    NSInteger cameraCount = [contextManager count:fetchRequest];
    
    if (cameraCount < configuredCameraCount) {
        for (int i = 0; i < (configuredCameraCount - cameraCount); i++) {
            Camera* camera = (Camera*)[NSEntityDescription insertNewObjectForEntityForName:@"Camera" inManagedObjectContext:contextManager.mainObjectContext];
            NSDictionary* configuredCamera = [configuredCameras objectAtIndex:(cameraCount + i)];
            camera.cameraId             = [configuredCamera objectForKey:@"cameraId"];
            camera.name                 = [configuredCamera objectForKey:@"name"];
            camera.imageFilename        = [configuredCamera objectForKey:@"imageFilename"];
            camera.hasParameter         = [configuredCamera objectForKey:@"hasParameter"];
            camera.maximumValue         = [configuredCamera objectForKey:@"maximumValue"];
            camera.minimumValue         = [configuredCamera objectForKey:@"minimumValue"];
            camera.value                = [configuredCamera objectForKey:@"value"];
            camera.hasAutoAdjust        = [configuredCamera objectForKey:@"hasAutoAdjust"];
            camera.autoAdjustEnabled    = [configuredCamera objectForKey:@"autoAdjustEnabled"];
            camera.hidden               = [configuredCamera objectForKey:@"hidden"];
            camera.purchased            = [configuredCamera objectForKey:@"purchased"];
            [contextManager save];
        }
    }
    
    return [contextManager fetch:fetchRequest];    
}

+ (NSDictionary*)loadCameraParameters {
    NSString* cameraFile = [[NSBundle  mainBundle] pathForResource:@"CameraFilterParameters" ofType:@"plist"];
    return [[NSDictionary dictionaryWithContentsOfFile:cameraFile] objectForKey:@"CameraFilterParameters"];
}

- (void)setCameraFilter:(GPUImageOutput<GPUImageInput>*)__filter forView:(GPUImageView*)__imageView {
    if (self.stillCamera) {
        [self.stillCamera stopCameraCapture];
        [self.stillCamera removeAllTargets];
        [self.filter removeAllTargets];
    }
    self.stillCamera = [[GPUImageStillCamera alloc] init];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.filter = _filter;
    [self.filter prepareForImageCapture];    
    [self.stillCamera addTarget:_filter];
    [self.filter addTarget:_imageView];  
    [self.stillCamera startCameraCapture];

}

- (void)captureStillImage:(void(^)(NSData* imageData, NSError* error))_completionHandler {
    [self.stillCamera capturePhotoAsJPEGProcessedUpToFilter:self.filter withCompletionHandler:_completionHandler];
}

- (CGFloat)scaledFilterValue:(NSNumber*)_value {
    CGFloat parameterRange = [self.camera.maximumValue floatValue] - [self.camera.minimumValue floatValue];
    return [_value floatValue ] / parameterRange;
}

- (NSNumber*)increasingParameter:(NSDictionary*)_parameter fromValue:(NSNumber*)_value {
    CGFloat mappedValue = 0.0f;
    CGFloat value = [_value floatValue];
    CGFloat initialValue = [[_parameter objectForKey:@"initialValue"] floatValue];
    CGFloat maximumValue = [[_parameter objectForKey:@"maximumValue"] floatValue];
    CGFloat minimumValue = [[_parameter objectForKey:@"minimumValue"] floatValue];
    CGFloat upperRange = (maximumValue - initialValue);
    CGFloat lowerRange = (initialValue - minimumValue);
    if (value > 0.5f) {
        mappedValue = 2.0f * upperRange * (value - 0.5f) + initialValue; 
    } else {
        mappedValue = 2.0f * lowerRange * value + minimumValue; 
    }
    return [NSNumber numberWithFloat:mappedValue];
}

- (NSNumber*)decreasingParameter:(NSDictionary*)_parameter fromValue:(NSNumber*)_value {
    CGFloat mappedValue = 0.0f;
    CGFloat value =[_value floatValue];
    CGFloat initialValue = [[_parameter objectForKey:@"initialValue"] floatValue];
    CGFloat maximumValue = [[_parameter objectForKey:@"maximumValue"] floatValue];
    CGFloat minimumValue = [[_parameter objectForKey:@"minimumValue"] floatValue];
    CGFloat upperRange = (initialValue - minimumValue);
    CGFloat lowerRange = (maximumValue - initialValue);
    if (value > 0.5f) {
        mappedValue = initialValue - 2.0f * upperRange * (value - 0.5f); 
    } else {
        mappedValue = maximumValue -  2.0f * lowerRange * value; 
    }
    return [NSNumber numberWithFloat:mappedValue];
}


// initial value is equal to maximum value
- (NSNumber*)mirroredMaximumParameter:(NSDictionary*)_parameter fromValue:(NSNumber*)_value {
    CGFloat mappedValue = 0.0f;
    CGFloat value = [_value floatValue];
    CGFloat initialValue = [[_parameter objectForKey:@"initialValue"] floatValue];
    CGFloat minimumValue = [[_parameter objectForKey:@"minimumValue"] floatValue];
    CGFloat range = (initialValue - minimumValue);
    if (value > 0.5f) {
        mappedValue = initialValue - 2.0f * range * (value - 0.5f); 
    } else {
        mappedValue = initialValue - 2.0f * range * (0.5f - value); 
    }
    return [NSNumber numberWithFloat:mappedValue];
}

// initial value is equal to minimum value
- (NSNumber*)mirroredMinimumParameter:(NSDictionary*)_parameter fromValue:(NSNumber*)_value {
    CGFloat mappedValue = 0.0f;
    CGFloat value =[_value floatValue];
    CGFloat initialValue = [[_parameter objectForKey:@"initialValue"] floatValue];
    CGFloat maximumValue = [[_parameter objectForKey:@"maximumValue"] floatValue];
    CGFloat range = (maximumValue - initialValue);
    if (value > 0.5f) {
        mappedValue = initialValue + 2.0f * range * (value - 0.5f); 
    } else {
        mappedValue = initialValue + 2.0f * range * (0.5f - value); 
    }
    return [NSNumber numberWithFloat:mappedValue];
}


#pragma mark -
#pragma mark CameraFactory (ParameterValues)

- (NSDictionary*)instantCameraParameterValues:(NSNumber*)_value {
    NSDictionary* parameters = [self.loadedCameraParameters objectForKey:@"Instant"];
    
    NSDictionary* rgbParameters = [parameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* greenParameters = [rgbParameters objectForKey:@"Green"];
    NSDictionary* redParameters = [rgbParameters objectForKey:@"Red"];
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self increasingParameter:blueParameters fromValue:_value],
                                                                         [self increasingParameter:greenParameters fromValue:_value],
                                                                         [self decreasingParameter:redParameters fromValue:_value], nil]
                                       forKeys:[NSArray arrayWithObjects:@"blue", @"green", @"red", nil]];
}

- (NSDictionary*)boxCameraParameterValues:(NSNumber*)_value {
    NSDictionary* parameters = [self.loadedCameraParameters objectForKey:@"Box"];
    
    NSDictionary* rgbParameters = [parameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* greenParameters = [rgbParameters objectForKey:@"Green"];
    NSDictionary* redParameters = [rgbParameters objectForKey:@"Red"];

    NSDictionary* vignetteParameters = [[parameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self decreasingParameter:blueParameters fromValue:_value],
                                                                         [self increasingParameter:greenParameters fromValue:_value],
                                                                         [self increasingParameter:redParameters fromValue:_value],
                                                                         [self mirroredMaximumParameter:vignetteParameters fromValue:_value], nil]
                         forKeys:[NSArray arrayWithObjects:@"blue", @"green", @"red", @"vignette", nil]];
}

- (NSDictionary*)plasticCameraParameterValues:(NSNumber*)_value {
    NSDictionary* parameters = [self.loadedCameraParameters objectForKey:@"Plastic"];

    NSDictionary* rgbParameters = [parameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* greenParameters = [rgbParameters objectForKey:@"Green"];
    NSDictionary* redParameters = [rgbParameters objectForKey:@"Red"];
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self increasingParameter:blueParameters fromValue:_value],
                                                [self increasingParameter:greenParameters fromValue:_value],
                                                [self decreasingParameter:redParameters fromValue:_value], nil]
                                       forKeys:[NSArray arrayWithObjects:@"blue", @"green", @"red", nil]];
}

#pragma mark -
#pragma mark CameraFactory (Initial Parameter Values)

- (NSDictionary*)initialInstantCameraParameterValues {
    NSDictionary* parameters = [self.loadedCameraParameters objectForKey:@"Instant"];
    
    NSDictionary* contrastParameters = [[parameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* vignetteParameters = [[parameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
    NSDictionary* rgbParameters = [parameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* saturationParameters = [[parameters objectForKey:@"GPUImageSaturationFilter"] objectForKey:@"Saturation"];
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[contrastParameters objectForKey:@"initialValue"],
                                                                         [blueParameters objectForKey:@"initialValue"],
                                                                         [saturationParameters objectForKey:@"initialValue"],
                                                                         [vignetteParameters objectForKey:@"initialValue"], nil]
                         forKeys:[NSArray arrayWithObjects:@"contrast", @"blue", @"saturation", @"vignette", nil]];
    
}

- (NSDictionary*)initialBoxCameraParameterValues {
    NSDictionary* parameters = [self.loadedCameraParameters objectForKey:@"Box"];
    
    NSDictionary* contrastParameters = [[parameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* vignetteParameters = [[parameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
    NSDictionary* rgbParameters = [parameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[contrastParameters objectForKey:@"initialValue"],
                                                                         [vignetteParameters objectForKey:@"initialValue"], 
                                                                         [blueParameters objectForKey:@"initialValue"], nil]
                         forKeys:[NSArray arrayWithObjects:@"contrast", @"vignette", @"blue", nil]];
    
}

- (NSDictionary*)initialPlasticCameraParameterValues {
    NSDictionary* parameters = [self.loadedCameraParameters objectForKey:@"Plastic"];
    
    NSDictionary* contrastParameters = [[parameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* rgbParameters = [parameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* saturationParameters = [[parameters objectForKey:@"GPUImageSaturationFilter"] objectForKey:@"Saturation"];
    NSDictionary* vignetteParameters = [[parameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[contrastParameters objectForKey:@"initialValue"],
                                                                         [blueParameters objectForKey:@"initialValue"],
                                                                         [saturationParameters objectForKey:@"initialValue"], 
                                                                         [vignetteParameters objectForKey:@"initialValue"], nil]
                         forKeys:[NSArray arrayWithObjects:@"contrast", @"blue", @"saturation", @"vignette", nil]];
    
}

#pragma mark -
#pragma mark CameraFactory (Filters)

- (GPUImageOutput<GPUImageInput>*)filterInstantCamera {
    SaturationCameraFilter* instantFilter = [[SaturationCameraFilter alloc] init];
    NSDictionary* parameters = [self initialInstantCameraParameterValues];
    [instantFilter setSaturation:[[parameters objectForKey:@"saturation"] floatValue]];
    [instantFilter setContrast:[[parameters objectForKey:@"contrast"] floatValue]];
    [instantFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [instantFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
    return instantFilter;
}

- (GPUImageOutput<GPUImageInput>*)filterBoxCamera {
    SaturationCameraFilter* boxFilter = [[SaturationCameraFilter alloc] init];
    NSDictionary* parameters = [self initialBoxCameraParameterValues];
    [boxFilter setSaturation:[[parameters objectForKey:@"saturation"] floatValue]];
    [boxFilter setContrast:[[parameters objectForKey:@"contrast"] floatValue]];
    [boxFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [boxFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
    return boxFilter;
}

- (GPUImageOutput<GPUImageInput>*)filterPlasticCamera {
    SaturationCameraFilter* plasticFilter = [[SaturationCameraFilter alloc] init];
    NSDictionary* parameters = [self initialPlasticCameraParameterValues];
    [plasticFilter setSaturation:[[parameters objectForKey:@"saturation"] floatValue]];
    [plasticFilter setContrast:[[parameters objectForKey:@"contrast"] floatValue]];
    [plasticFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [plasticFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
    return plasticFilter;
}


#pragma mark -
#pragma mark CameraFactory (SetParameterValues)

- (void)setInstantCameraParameterValue:(NSNumber*)_value forFilter:(GPUImageOutput<GPUImageInput>*)_filter {
    NSDictionary* parameters = [self instantCameraParameterValues:_value];
    SaturationCameraFilter* instantFilter = (SaturationCameraFilter*)_filter;
    [instantFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [instantFilter setGreen:[[parameters objectForKey:@"green"] floatValue]];
    [instantFilter setRed:[[parameters objectForKey:@"red"] floatValue]];
}

- (void)setBoxCameraParameterValue:(NSNumber*)_value forFilter:(GPUImageOutput<GPUImageInput>*)_filter {
    NSDictionary* parameters = [self boxCameraParameterValues:_value];
    SaturationCameraFilter* boxFilter = (SaturationCameraFilter*)_filter;
    [boxFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [boxFilter setGreen:[[parameters objectForKey:@"green"] floatValue]];
    [boxFilter setRed:[[parameters objectForKey:@"red"] floatValue]];
    [boxFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
}

- (void)setPlasticCameraParameterValue:(NSNumber*)_value forFilter:(GPUImageOutput<GPUImageInput>*)_filter {
    NSDictionary* parameters = [self plasticCameraParameterValues:_value];
    SaturationCameraFilter* plasticFilter = (SaturationCameraFilter*)_filter;
    [plasticFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [plasticFilter setGreen:[[parameters objectForKey:@"green"] floatValue]];
    [plasticFilter setRed:[[parameters objectForKey:@"red"] floatValue]];
}

#pragma mark -
#pragma mark CameraFactory

+ (CameraFactory*)instance {
    @synchronized(self) {
        if (thisCameraFactory == nil) {
            thisCameraFactory = [[self alloc] init];
            thisCameraFactory.loadedCameras = [self loadCameras];
            thisCameraFactory.loadedCameraParameters = [self loadCameraParemeters];
        }
    }
    return thisCameraFactory;
}

- (void)setCamera:(Camera*)_camera forView:(GPUImageView*)_imageView {
    self.camera = _camera;
    switch ([_camera.cameraId intValue]) {
        case CameraTypeIPhone:
            [self setCameraFilter:[[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"PassThrough"] forView:_imageView];
            break;
        case CameraTypeInstant:
            [self setCameraFilter:[self filterInstantCamera] forView:_imageView];
            break;  
        case CameraTypeBox:
            [self setCameraFilter:[self filterBoxCamera] forView:_imageView];
            break;
        case CameraTypePlastic:
            [self setCameraFilter:[self filterPlasticCamera] forView:_imageView];
            break;
        default:
            break;
    }
    [self setCameraParmeterValue:_camera.value];
}

- (void)setCameraParmeterValue:(NSNumber*)_value {
    self.camera.value = _value;
    [[DataContextManager instance] save];
    switch ([self.camera.cameraId intValue]) {
        case CameraTypeIPhone:
            break;
        case CameraTypeInstant:
            [self setInstantCameraParameterValue:_value forFilter:self.filter];
            break; 
        case CameraTypeBox:
            [self setBoxCameraParameterValue:_value forFilter:self.filter];
            break;
        case CameraTypePlastic:
            [self setPlasticCameraParameterValue:_value forFilter:self.filter];
            break;
        default:
            break;
    }
}

- (Camera*)defaultCamera {
    return [self.loadedCameras objectAtIndex:CameraTypeIPhone];
}

- (NSArray*)cameras {
    return self.loadedCameras;
}


@end
