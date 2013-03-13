//
//  SaturationFilter.h
//  photio
//
//  Created by Troy Stribling on 6/24/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "GPUImageFilter.h"

@interface SaturationFilter : GPUImageFilter

@property(nonatomic, assign) CGFloat saturation;
@property(nonatomic, assign) CGFloat contrast;
@property(nonatomic, assign) CGFloat red;
@property(nonatomic, assign) CGFloat green;
@property(nonatomic, assign) CGFloat blue;
@property(nonatomic, assign) CGPoint vignetteCenter;
@property(nonatomic, assign) GPUVector3 vignetteColor;
@property(nonatomic, assign) CGFloat vignetteStart;
@property(nonatomic, assign) CGFloat vignetteEnd;

@end
