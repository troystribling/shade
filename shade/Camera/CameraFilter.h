//
//  CameraFilter.h
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageFilter.h"

@interface CameraFilter : NSObject

@property(nonatomic, strong) GPUImageOutput<GPUImageInput>  *filter;
@property(nonatomic, strong) NSDictionary                   *filterParameters;

- (id)initWithParameters:(NSDictionary*)__parameters;
- (NSNumber*)increasingParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value;
- (NSNumber*)decreasingParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value;
- (NSNumber*)mirroredMaximumParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value;
- (NSNumber*)mirroredMinimumParameter:(NSDictionary*)__parameter fromValue:(NSNumber*)__value;

- (NSDictionary*)initialParameterValues;
- (GPUImageOutput<GPUImageInput>*)createFilter;
- (NSDictionary*)parameterValues:(NSNumber*)__value;
- (void)setParameterValue:(NSNumber*)__value;

@end
