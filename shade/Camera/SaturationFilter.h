//
//  SaturationFilter.h
//  photio
//
//  Created by Troy Stribling on 6/24/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "GPUImageFilter.h"

@interface SaturationFilter : GPUImageFilter {

    GLint saturationUniform;

    GLint contrastUniform;

    GLint redUniform;
    GLint greenUniform;
    GLint blueUniform;
    
    GLint vignetteStartUniform;
    GLint vignetteEndUniform;
}

@property(readwrite, nonatomic) CGFloat saturation; 

@property(readwrite, nonatomic) CGFloat contrast; 

@property (readwrite, nonatomic) CGFloat red; 
@property (readwrite, nonatomic) CGFloat green; 
@property (readwrite, nonatomic) CGFloat blue;

@property (nonatomic, readwrite) CGFloat vignetteStart;
@property (nonatomic, readwrite) CGFloat vignetteEnd;

@end
