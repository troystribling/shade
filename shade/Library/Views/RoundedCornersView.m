//
//  RoundedCornersView.m
//  photio
//
//  Created by Troy Stribling on 5/5/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "RoundedCornersView.h"
#import <QuartzCore/QuartzCore.h>

@interface RoundedCornersView ()

- (void)configureLayer;

@end

@implementation RoundedCornersView

- (void)configureLayer {
    self.layer.cornerRadius = 20.0f;
    self.layer.borderColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0].CGColor;
    self.layer.borderWidth = 1.0f;
}

+ (id)withFrame:(CGRect)_frame {
    RoundedCornersView* roundedView = [[RoundedCornersView alloc] initWithFrame:_frame];
    [roundedView configureLayer];
    return roundedView;
}

- (id)initWithCoder:(NSCoder *)coder { 
    self = [super initWithCoder:coder];
    if (self) {
        [self configureLayer];
    }
    return self;
}

@end
