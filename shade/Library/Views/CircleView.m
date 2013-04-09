//
//  CircleView.m
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "CircleView.h"
#import <QuartzCore/QuartzCore.h>

#define CIRCLE_VIEW_BORDER_WIDTH    1.0f
#define CIRCLE_VIEW_ALPHA           0.5f

@implementation CircleView

+ (id)withRadius:(float)__radius centeredAt:(CGPoint)__center {
    return [[CircleView alloc] initWithRadius:__radius centeredAt:__center];
}

- (id)initWithRadius:(float)__radius centeredAt:(CGPoint)__center {
    CGRect circleRect = CGRectMake(0.0f, 0.0f, 2.0f * __radius, 2.0f * __radius);
    self = [super initWithFrame:circleRect];
    if (self) {
        self.layer.cornerRadius = __radius;
        self.layer.borderWidth = CIRCLE_VIEW_BORDER_WIDTH;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = CIRCLE_VIEW_ALPHA;
        self.center = CGPointMake(__center.x, __center.y);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

@end
