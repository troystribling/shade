//
//  TextBoxView.m
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "TextBoxView.h"
#import "BorderedView.h"

#define DISPLAY_MESSAGE_XOFFEST     15.0
#define DISPLAY_MESSAGE_YOFFEST     10.0

@interface TextBoxView ()

- (void)addViewsWithText:(NSString*)__text ofSize:(CGSize)__messageSize;

@end

@implementation TextBoxView

+ (id)withText:(NSString*)__text andWidth:(float)__width {
    return [[self alloc] initWithText:__text constrainedToWidth:__width];
}

+ (id)withText:(NSString*)__text {
    return [[self alloc] initWithText:__text];
}

- (void)addViewsWithText:(NSString*)__text ofSize:(CGSize)__messageSize {
    CGRect messageLabelRect = CGRectMake(self.center.x - 0.5 * __messageSize.width,
                                         self.center.y - 0.5 * __messageSize.height,
                                         __messageSize.width,
                                         __messageSize.height);
    self.textLabel = [[UILabel alloc] initWithFrame:messageLabelRect];
    self.textLabel.text = __text;
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.font = [UIFont systemFontOfSize:21.0];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.alpha = 1.0;
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    CGRect displayViewRect = CGRectMake(self.center.x - 0.5 * __messageSize.width - DISPLAY_MESSAGE_XOFFEST,
                                        self.center.y - 0.5 * __messageSize.height - DISPLAY_MESSAGE_YOFFEST,
                                        __messageSize.width +  2.0 * DISPLAY_MESSAGE_XOFFEST,
                                        __messageSize.height + 2 * DISPLAY_MESSAGE_YOFFEST);

    self.frame = displayViewRect;
    self.backgroundView = [BorderedView withFrame:displayViewRect];
    self.backgroundView.alpha = .5;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.textLabel];
}

- (id)initWithText:(NSString*)__text constrainedToWidth:(float)__width {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGSize messageSize = [__text sizeWithFont:[UIFont systemFontOfSize:21.0]
                                constrainedToSize:CGSizeMake(__width, self.frame.size.height)
                                    lineBreakMode:NSLineBreakByWordWrapping];
        
        [self addViewsWithText:__text ofSize:messageSize];
    }
    return self;
}

- (id)initWithText:(NSString*)__text {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CGSize messageSize = [__text sizeWithFont:[UIFont systemFontOfSize:21.0]];
        [self addViewsWithText:__text ofSize:messageSize];
    }
    return self;
}

@end
