//
//  CircleView.m
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

+ (id)withRadius:(float)__radius centeredAt:(CGPoint)__center {
    return [[CircleView alloc] initWithRadius:__radius centeredAt:__center];
}

- (id)initWithRadius:(float)__radius centeredAt:(CGPoint)__center {
    CGRect circleRect = CGRectMake(0.0f, 0.0f, 2.0f * __radius, 2.0f * __radius);
    self = [super initWithFrame:circleRect];
    if (self) {
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

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor whiteColor].CGColor));
    CGContextSetAlpha(ctx, 0.5);
    CGContextFillEllipseInRect(ctx, rect);
    CGContextFillPath(ctx);
}

@end
