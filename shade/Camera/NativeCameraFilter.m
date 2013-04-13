//
//  NativeCameraFilter.m
//  shade
//
//  Created by Troy Stribling on 4/12/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "NativeCameraFilter.h"
#import "BrightnessContrastFilter.h"
#import "Camera+Extensions.h"

@implementation NativeCameraFilter

- (id)init {
    self = [super init];
    if (self) {
        self.filterParameters = [[Camera loadCameraParameters] objectForKey:@"Native"];
        self.filter = [self createFilter];
    }
    return self;
}

- (NSDictionary*)initialParameterValues {
    NSDictionary* contrastParameters = [[self.filterParameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* brightnessParameters = [[self.filterParameters objectForKey:@"GPUImageBrightnessFilter"] objectForKey:@"Brightness"];
    
    return @{@"contrast":   [contrastParameters objectForKey:@"initialValue"],
             @"brightness" :  [brightnessParameters objectForKey:@"initialValue"]};
}

- (GPUImageOutput<GPUImageInput>*)createFilter {
    BrightnessContrastFilter* brightnessContrastFilter = [[BrightnessContrastFilter alloc] init];
    NSDictionary* parameters = [self initialParameterValues];
    [brightnessContrastFilter setContrast:[[parameters objectForKey:@"contrast"] floatValue]];
    [brightnessContrastFilter setBrightness:[[parameters objectForKey:@"brightness"] floatValue]];
    return brightnessContrastFilter;
}

- (NSDictionary*)parameterValues:(NSNumber*)__value {
    NSDictionary* contrastParameters = [[self.filterParameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* brightnessParameters = [[self.filterParameters objectForKey:@"GPUImageBrightnessFilter"] objectForKey:@"Brightness"];
    return @{@"contrast":   [self increasingParameter:contrastParameters fromValue:__value],
             @"brightness":  [self increasingParameter:brightnessParameters fromValue:__value]};
}

- (void)setParameterValue:(NSNumber*)__value {
    NSDictionary* parameters = [self parameterValues:__value];
    BrightnessContrastFilter* filter = (BrightnessContrastFilter*)self.filter;
    [filter setContrast:[[parameters objectForKey:@"contrast"] floatValue]];
    [filter setBrightness:[[parameters objectForKey:@"brightness"] floatValue]];
}

@end
