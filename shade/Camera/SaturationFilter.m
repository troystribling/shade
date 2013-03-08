//
//  SaturationFilter.m
//  photio
//
//  Created by Troy Stribling on 6/24/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "SaturationFilter.h"

NSString *const kSaturationFilterFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform lowp float saturation;
 uniform lowp float contrast;

 uniform highp float red;
 uniform highp float green;
 uniform highp float blue;

 uniform highp float vignetteStart;
 uniform highp float vignetteEnd;

 const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
     lowp vec3 greyScaleColor = vec3(luminance);
     
     highp vec4 stauration_filter =  vec4(mix(greyScaleColor, textureColor.rgb, saturation), textureColor.w);
     highp vec4 contrast_filter = vec4(((stauration_filter.rgb - vec3(0.5)) * contrast + vec3(0.5)), stauration_filter.w);
     highp vec4 rgb_filter = vec4(contrast_filter.r * red, contrast_filter.g * green, contrast_filter.b * blue, 1.0);
     
     lowp float d = distance(textureCoordinate, vec2(0.5,0.5));
     rgb_filter.rgb *= smoothstep(vignetteEnd, vignetteStart, d);
     gl_FragColor = vec4(vec3(rgb_filter.rgb),1.0);
 }
 );

@implementation SaturationFilter

@synthesize saturation = _saturation;
@synthesize contrast = _contrast;
@synthesize red = _red, blue = _blue, green = _green;
@synthesize vignetteStart =_vignetteStart, vignetteEnd = _vignetteEnd;

#pragma mark -
#pragma mark SaturationFilter

- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kSaturationFilterFragmentShaderString])) {
		return nil;
    }
    
    saturationUniform = [filterProgram uniformIndex:@"saturation"];
    self.saturation = 1.0;

    contrastUniform = [filterProgram uniformIndex:@"contrast"];
    self.contrast = 1.0;

    redUniform = [filterProgram uniformIndex:@"red"];
    self.red = 1.0;
    greenUniform = [filterProgram uniformIndex:@"green"];
    self.green = 1.0;
    blueUniform = [filterProgram uniformIndex:@"blue"];
    self.blue = 1.0;
    
    vignetteStartUniform = [filterProgram uniformIndex:@"vignetteStart"];
    self.vignetteStart = 0.3;
    vignetteEndUniform = [filterProgram uniformIndex:@"vignetteEnd"];    
    self.vignetteEnd = 0.75;

    return self;
}

#pragma mark -
#pragma mark Saturation

- (void)setSaturation:(CGFloat)newValue {
    _saturation = newValue;
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(saturationUniform, _saturation);
}

#pragma mark -
#pragma mark Contrast


- (void)setContrast:(CGFloat)newValue {
    _contrast = newValue;    
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(contrastUniform, _contrast);
}

#pragma mark -
#pragma mark RGB Filter


- (void)setRed:(CGFloat)newValue {
    _red = newValue;
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(redUniform, _red);
}

- (void)setGreen:(CGFloat)newValue {
    _green = newValue;
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(greenUniform, _green);
}


- (void)setBlue:(CGFloat)newValue {
    _blue = newValue;
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(blueUniform, _blue);
}

#pragma mark -
#pragma mark Vignette

- (void)setVignetteStart:(CGFloat)newValue {
    _vignetteStart = newValue;
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(vignetteStartUniform, _vignetteStart);
}

- (void)setVignetteEnd:(CGFloat)newValue {
    _vignetteEnd = newValue;
    [GPUImageOpenGLESContext useImageProcessingContext];
    [filterProgram use];
    glUniform1f(vignetteEndUniform, _vignetteEnd);
}


@end
