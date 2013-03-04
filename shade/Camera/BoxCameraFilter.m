//
//  BoxCameraFilter.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "BoxCameraFilter.h"
#import "SaturationCameraFilter.m"

@implementation BoxCameraFilter

- (NSDictionary*)initialParameterValues {    
    NSDictionary* contrastParameters = [[self.filterParameters objectForKey:@"GPUImageContrastFilter"] objectForKey:@"Contrast"];
    NSDictionary* vignetteParameters = [[self.filterParameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
    NSDictionary* rgbParameters = [self.filterParameters objectForKey:@"GPUImageRGBFilter"];
    NSDictionary* blueParameters = [rgbParameters objectForKey:@"Blue"];
    
    return @{@"contrast":   [contrastParameters objectForKey:@"initialValue"],
             @"vignette":   [vignetteParameters objectForKey:@"initialValue"],
             @"blue":       [blueParameters objectForKey:@"initialValue"]};
}

- (GPUImageOutput<GPUImageInput>*)initFilter {
    SaturationCameraFilter* boxFilter = [[SaturationCameraFilter alloc] init];
    NSDictionary* parameters = [self initialBoxCameraParameterValues];
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
    
    NSDictionary* vignetteParameters = [[parameters objectForKey:@"GPUImageVignetteFilter"] objectForKey:@"VignetteEnd"];
 
    return @{@"blue":       [self decreasingParameter:blueParameters fromValue:__value],
             @"green":      [self increasingParameter:greenParameters fromValue:__value],
             @"red":        [self increasingParameter:redParameters fromValue:__value],
             @"vignette":   [self mirroredMaximumParameter:vignetteParameters fromValue:__value]}
}

- (void)setParameterValue:(NSNumber*)__value {
    NSDictionary* parameters = [self parameterValues:_value];
    SaturationCameraFilter* boxFilter = (SaturationCameraFilter*)self.filter;
    [boxFilter setBlue:[[parameters objectForKey:@"blue"] floatValue]];
    [boxFilter setGreen:[[parameters objectForKey:@"green"] floatValue]];
    [boxFilter setRed:[[parameters objectForKey:@"red"] floatValue]];
    [boxFilter setVignetteEnd:[[parameters objectForKey:@"vignette"] floatValue]];
}

@end
