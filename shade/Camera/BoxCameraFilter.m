//
//  BoxCameraFilter.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "BoxCameraFilter.h"
#import "SaturationFilter.h"
#import "Camera+Extensions.h" 
#import "GPUImage.h"

@implementation BoxCameraFilter

- (id)init {
    self = [super init];
    if (self) {
        self.filterParameters = [[Camera loadCameraParameters] objectForKey:@"Box"];
        self.filter = [self createFilter];
    }
    return self;
}

- (NSDictionary*)initialParameterValues {    
    NSDictionary* saturationParameters = [[self.filterParameters objectForKey:@"GPUImageSaturationFilter"] objectForKey:@"Saturation"];
    NSDictionary* contrastParameters = [[self.filterParameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* vignetteParameters = [[self.filterParameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
    NSDictionary* rgbParameters = [self.filterParameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    
    return @{@"saturation": [saturationParameters objectForKey:@"initialValue"],
             @"contrast":   [contrastParameters objectForKey:@"initialValue"],
             @"vignette":   [vignetteParameters objectForKey:@"initialValue"],
             @"blue":       [blueParameters objectForKey:@"initialValue"]};
}

- (GPUImageOutput<GPUImageInput>*)createFilter {
    SaturationFilter* boxFilter = [[SaturationFilter alloc] init];
    NSDictionary* parameters = [self initialParameterValues];
    [boxFilter setSaturation:[[parameters objectForKey:@"saturation"] floatValue]];
    [boxFilter setContrast:[[parameters objectForKey:@"contrast"] floatValue]];
    [boxFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [boxFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
    return boxFilter;
}

- (NSDictionary*)parameterValues:(NSNumber*)__value {    
    NSDictionary* rgbParameters = [self.filterParameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* greenParameters = [rgbParameters objectForKey:@"Green"];
    NSDictionary* redParameters = [rgbParameters objectForKey:@"Red"];
    
    NSDictionary* vignetteParameters = [[self.filterParameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
 
    return @{@"blue":       [self decreasingParameter:blueParameters fromValue:__value],
             @"green":      [self increasingParameter:greenParameters fromValue:__value],
             @"red":        [self increasingParameter:redParameters fromValue:__value],
             @"vignette":   [self mirroredMaximumParameter:vignetteParameters fromValue:__value]};
}

- (void)setParameterValue:(NSNumber*)__value {
    NSDictionary* parameters = [self parameterValues:__value];
    SaturationFilter* boxFilter = (SaturationFilter*)self.filter;
    [boxFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [boxFilter setGreen:[[parameters objectForKey:@"green"] floatValue]];
    [boxFilter setRed:[[parameters objectForKey:@"red"] floatValue]];
    [boxFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
}

@end
