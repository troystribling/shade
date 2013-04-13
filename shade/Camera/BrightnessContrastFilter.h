//
//  BrightnessContrastFilter.h
//  shade
//
//  Created by Troy Stribling on 4/12/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "GPUImageFilter.h"

@interface BrightnessContrastFilter : GPUImageFilter

@property(nonatomic, assign) CGFloat contrast;
@property(nonatomic, assign) CGFloat brightness;

@end
