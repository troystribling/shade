//
//  PlasticCameraFilter.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "PlasticCameraFilter.h"
#import "SaturationFilter.h"
#import "Camera+Extensions.h"

@implementation PlasticCameraFilter

- (id)init {
    self = [super init];
    if (self) {
        self.filterParameters = [[Camera loadCameraParameters] objectForKey:@"Plastic"];
        self.filter = [self createFilter];
    }
    return self;
}

- (NSDictionary*)initialParameterValues {
    NSDictionary* contrastParameters = [[self.filterParameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* rgbParameters = [self.filterParameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    NSDictionary* saturationParameters = [[self.filterParameters objectForKey:@"GPUImageSaturationFilter"] objectForKey:@"Saturation"];
    NSDictionary* vignetteParameters = [[self.filterParameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
    return @{@"contrast":   [contrastParameters objectForKey:@"initialValue"],
             @"blue":       [blueParameters objectForKey:@"initialValue"],
             @"saturation": [saturationParameters objectForKey:@"initialValue"],
             @"vignette":   [vignetteParameters objectForKey:@"initialValue"]};
}

- (GPUImageOutput<GPUImageInput>*)createFilter {
    SaturationFilter* plasticFilter = [[SaturationFilter alloc] init];
    NSDictionary* parameters = [self initialParameterValues];
    [plasticFilter setSaturation:[[parameters objectForKey:@"saturation"] floatValue]];
    [plasticFilter setContrast:[[parameters objectForKey:@"contrast"] floatValue]];
    [plasticFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [plasticFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
    return plasticFilter;
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

- (void)setParameterValue:(NSNumber*)__value{
    NSDictionary* parameters = [self parameterValues:__value];
    SaturationFilter* plasticFilter = (SaturationFilter*)self.filter;
    [plasticFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [plasticFilter setGreen:[[parameters objectForKey:@"green"] floatValue]];
    [plasticFilter setRed:[[parameters objectForKey:@"red"] floatValue]];
}

@end
