//
//  BorderedView.m
//  photio
//
//  Created by Troy Stribling on 5/5/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "BorderedView.h"
#import <QuartzCore/QuartzCore.h>

@interface BorderedView ()

- (void)configureLayer;

@end

@implementation BorderedView

+ (id)withFrame:(CGRect)_frame {
    return [[BorderedView alloc] initWithFrame:_frame];
}

- (id)initWithCoder:(NSCoder *)coder { 
    self = [super initWithCoder:coder];
    if (self) {
        [self configureLayer];
    }
    return self;
}

- (void)setBorderColor:(UIColor*)__color {
    self.layer.borderColor = __color.CGColor;
}

- (void)configureLayer {
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1.0f;
}


@end
