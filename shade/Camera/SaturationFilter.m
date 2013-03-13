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
 uniform lowp vec2 vignetteCenter;
 uniform lowp vec3 vignetteColor;
 uniform highp float vignetteStart;
 uniform highp float vignetteEnd;

 // Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
 const mediump vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float luminance = dot(textureColor.rgb, luminanceWeighting);
     lowp vec3 greyScaleColor = vec3(luminance);
     
     highp vec4 stauration_filter = vec4(mix(greyScaleColor, textureColor.rgb, saturation), textureColor.w);
     highp vec4 contrast_filter = vec4(((stauration_filter.rgb - vec3(0.5)) * contrast + vec3(0.5)), stauration_filter.w);
     highp vec4 rgb_filter = vec4(contrast_filter.r * red, contrast_filter.g * green, contrast_filter.b * blue, 1.0);
     
     lowp float d = distance(textureCoordinate, vec2(vignetteCenter.x, vignetteCenter.y));
     lowp float percent = smoothstep(vignetteStart, vignetteEnd, d);
     gl_FragColor = vec4(mix(rgb_filter.rgb.x, vignetteColor.x, percent), mix(rgb_filter.rgb.y, vignetteColor.y, percent), mix(rgb_filter.rgb.z, vignetteColor.z, percent), 1.0);
 }
);

@interface SaturationFilter () {
    GLint saturationUniform;
    GLint contrastUniform;
    GLint redUniform;
    GLint greenUniform;
    GLint blueUniform;
    GLint vignetteCenterUniform, vignetteColorUniform, vignetteStartUniform, vignetteEndUniform;
}
@end

@implementation SaturationFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kSaturationFilterFragmentShaderString]))
    {
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

    vignetteCenterUniform = [filterProgram uniformIndex:@"vignetteCenter"];
    vignetteColorUniform = [filterProgram uniformIndex:@"vignetteColor"];
    vignetteStartUniform = [filterProgram uniformIndex:@"vignetteStart"];
    vignetteEndUniform = [filterProgram uniformIndex:@"vignetteEnd"];
    
    self.vignetteCenter = (CGPoint){ 0.5f, 0.5f };
    self.vignetteColor = (GPUVector3){ 0.0f, 0.0f, 0.0f };
    self.vignetteStart = 0.3;
    self.vignetteEnd = 0.75;

    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setSaturation:(CGFloat)newValue {
    _saturation = newValue;
    [self setFloat:_saturation forUniform:saturationUniform program:filterProgram];
}

- (void)setContrast:(CGFloat)newValue {
    _contrast = newValue;
    [self setFloat:_contrast forUniform:contrastUniform program:filterProgram];
}

- (void)setRed:(CGFloat)newValue {
    _red = newValue;
    [self setFloat:_red forUniform:redUniform program:filterProgram];
}

- (void)setGreen:(CGFloat)newValue {
    _green = newValue;
    [self setFloat:_green forUniform:greenUniform program:filterProgram];
}

- (void)setBlue:(CGFloat)newValue {
    _blue = newValue;
    [self setFloat:_blue forUniform:blueUniform program:filterProgram];
}

- (void)setVignetteCenter:(CGPoint)newValue {
    _vignetteCenter = newValue;
    [self setPoint:_vignetteCenter forUniform:vignetteCenterUniform program:filterProgram];
}

- (void)setVignetteColor:(GPUVector3)newValue {
    _vignetteColor = newValue;
    [self setVec3:_vignetteColor forUniform:vignetteColorUniform program:filterProgram];
}

- (void)setVignetteStart:(CGFloat)newValue {
    _vignetteStart = newValue;
    [self setFloat:_vignetteStart forUniform:vignetteStartUniform program:filterProgram];
}

- (void)setVignetteEnd:(CGFloat)newValue {
    _vignetteEnd = newValue;
    [self setFloat:_vignetteEnd forUniform:vignetteEndUniform program:filterProgram];
}

@end
