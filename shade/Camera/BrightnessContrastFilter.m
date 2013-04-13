//
//  BrightnessContrastFilter.m
//  shade
//
//  Created by Troy Stribling on 4/12/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "BrightnessContrastFilter.h"

NSString *const kBrightnessContrastFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float contrast;
 uniform lowp float brightness;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = vec4((textureColor.rgb + vec3(brightness)), textureColor.w);
 }
);

@interface BrightnessContrastFilter () {
    GLint contrastUniform;
    GLint brightnessUniform;
}
@end

@implementation BrightnessContrastFilter

- (id)init; {
    self = [super initWithFragmentShaderFromString:kBrightnessContrastFragmentShaderString];
    if (self) {
        contrastUniform = [filterProgram uniformIndex:@"contrast"];
        self.contrast = 1.0;
        brightnessUniform = [filterProgram uniformIndex:@"brightness"];
        self.brightness = 0.0;
    }
    
    return self;
}

- (void)setBrightness:(CGFloat)newValue; {
    _brightness = newValue;
    [self setFloat:_brightness forUniform:brightnessUniform program:filterProgram];
}

- (void)setContrast:(CGFloat)newValue; {
    _contrast = newValue;
    [self setFloat:_contrast forUniform:contrastUniform program:filterProgram];
}

@end
