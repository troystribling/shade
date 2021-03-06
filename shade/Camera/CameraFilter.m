//
//  CameraFilter.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "CameraFilter.h"
#import "GPUImage.h"

@implementation CameraFilter

+ (UIImage*)outputImageForFilter:(GPUImageOutput<GPUImageInput>*)__filter andImage:(UIImage*)__image {
    GPUImagePicture* filteredImage = [[GPUImagePicture alloc] initWithImage:__image];
    [filteredImage addTarget:__filter];
    [filteredImage processImage];
    return [__filter imageFromCurrentlyProcessedOutputWithOrientation:__image.imageOrientation];
}

- (id)initWithParameters:(NSDictionary*)__parameters {
    self = [self init];
    if (self) {
        self.filterParameters = __parameters;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSNumber*)increasingParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value {
    CGFloat mappedValue = 0.0f;
    CGFloat value = [__value floatValue];
    CGFloat initialValue = [[__parameter objectForKey:@"initialValue"] floatValue];
    CGFloat maximumValue = [[__parameter objectForKey:@"maximumValue"] floatValue];
    CGFloat minimumValue = [[__parameter objectForKey:@"minimumValue"] floatValue];
    CGFloat upperRange = (maximumValue - initialValue);
    CGFloat lowerRange = (initialValue - minimumValue);
    if (value > 0.5f) {
        mappedValue = 2.0f * upperRange * (value - 0.5f) + initialValue;
    } else {
        mappedValue = 2.0f * lowerRange * value + minimumValue;
    }
    return [NSNumber numberWithFloat:mappedValue];
}

- (NSNumber*)decreasingParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value {
    CGFloat mappedValue = 0.0f;
    CGFloat value =[__value floatValue];
    CGFloat initialValue = [[__parameter objectForKey:@"initialValue"] floatValue];
    CGFloat maximumValue = [[__parameter objectForKey:@"maximumValue"] floatValue];
    CGFloat minimumValue = [[__parameter objectForKey:@"minimumValue"] floatValue];
    CGFloat upperRange = (initialValue - minimumValue);
    CGFloat lowerRange = (maximumValue - initialValue);
    if (value > 0.5f) {
        mappedValue = initialValue - 2.0f * upperRange * (value - 0.5f);
    } else {
        mappedValue = maximumValue -  2.0f * lowerRange * value;
    }
    return [NSNumber numberWithFloat:mappedValue];
}

- (NSNumber*)mirroredMaximumParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value {
    CGFloat mappedValue = 0.0f;
    CGFloat value = [__value floatValue];
    CGFloat initialValue = [[__parameter objectForKey:@"initialValue"] floatValue];
    CGFloat minimumValue = [[__parameter objectForKey:@"minimumValue"] floatValue];
    CGFloat range = (initialValue - minimumValue);
    if (value > 0.5f) {
        mappedValue = initialValue - 2.0f * range * (value - 0.5f);
    } else {
        mappedValue = initialValue - 2.0f * range * (0.5f - value);
    }
    return [NSNumber numberWithFloat:mappedValue];
}

- (NSNumber*)mirroredMinimumParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value {
    CGFloat mappedValue = 0.0f;
    CGFloat value =[__value floatValue];
    CGFloat initialValue = [[__parameter objectForKey:@"initialValue"] floatValue];
    CGFloat maximumValue = [[__parameter objectForKey:@"maximumValue"] floatValue];
    CGFloat range = (maximumValue - initialValue);
    if (value > 0.5f) {
        mappedValue = initialValue + 2.0f * range * (value - 0.5f);
    } else {
        mappedValue = initialValue + 2.0f * range * (0.5f - value);
    }
    return [NSNumber numberWithFloat:mappedValue];
}

- (UIImage*)applyParameterValue:(NSNumber*)__value toImage:(UIImage*)__image {
    [self setParameterValue:__value];
    return [self.class outputImageForFilter:self.filter andImage:__image];
}

#pragma mark -
#pragma mark Interface
- (NSDictionary*)initialParameterValues {
    return [NSDictionary dictionary];
}

- (GPUImageOutput<GPUImageInput>*)createFilter {
    return nil;
}

- (NSDictionary*)parameterValues:(NSNumber*)__value {
    return [NSDictionary dictionary];
}

- (void)setParameterValue:(NSNumber*)__value {    
}

@end
