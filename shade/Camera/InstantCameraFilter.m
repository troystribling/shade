//
//  InstantCameraFilter.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "InstantCameraFilter.h"
#import "SaturationFilter.h"
#import "Camera+Extensions.h"

@implementation InstantCameraFilter

- (id)init {
    self = [super init];
    if (self) {
        self.filterParameters = [[Camera loadCameraParameters] objectForKey:@"Instant"];
    }
    return self;
}

- (NSDictionary*)initialParameterValues {
    NSDictionary* contrastParameters = [[self.filterParameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* vignetteParameters = [[self.filterParameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
    NSDictionary* rgbParameters = [self.filterParameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* saturationParameters = [[self.filterParameters objectForKey:@"GPUImageSaturationFilter"] objectForKey:@"Saturation"];
    
    return @{@"contrast":   [contrastParameters objectForKey:@"initialValue"],
             @"blue":       [blueParameters objectForKey:@"initialValue"],
             @"saturation": [saturationParameters objectForKey:@"initialValue"],
             @"vignette" :  [vignetteParameters objectForKey:@"initialValue"]};    
}

- (GPUImageOutput<GPUImageInput>*)createFilter {
    SaturationFilter* instantFilter = [[SaturationFilter alloc] init];
    NSDictionary* parameters = [self initialParameterValues];
    [instantFilter setSaturation:[[parameters objectForKey:@"saturation"] floatValue]];
    [instantFilter setContrast:[[parameters objectForKey:@"contrast"] floatValue]];
    [instantFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [instantFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
    return instantFilter;
}

- (NSDictionary*)parameterValues:(NSNumber*)__value {
    NSDictionary* rgbParameters = [self.filterParameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* greenParameters = [rgbParameters objectForKey:@"Green"];
    NSDictionary* redParameters = [rgbParameters objectForKey:@"Red"];
    
    return @{@"blue":   [self increasingParameter:blueParameters fromValue:__value],
             @"green":  [self increasingParameter:greenParameters fromValue:__value],
             @"red":    [self decreasingParameter:redParameters fromValue:__value]};
}

- (void)setParameterValue:(NSNumber*)__value {
    NSDictionary* parameters = [self parameterValues:__value];
    SaturationFilter* instantFilter = (SaturationFilter*)self.filter;
    [instantFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [instantFilter setGreen:[[parameters objectForKey:@"green"] floatValue]];
    [instantFilter setRed:[[parameters objectForKey:@"red"] floatValue]];
}

@end
