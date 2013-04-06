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

- (void)addViewsWithText:(NSString*)__text constrainedToWidth:(float)__width;

@end

@implementation TextBoxView

+ (id)withText:(NSString*)__text andWidth:(float)__width {
    return [[self alloc] initWithText:__text constrainedToWidth:__width];
}

- (void)addViewsWithText:(NSString*)__text constrainedToWidth:(float)__width {
    CGSize messageSize = [__text sizeWithFont:[UIFont systemFontOfSize:21.0]
                             constrainedToSize:CGSizeMake(__width, self.frame.size.height)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect messageLabelRect = CGRectMake(self.center.x - 0.5 * __width,
                                         self.center.y - 0.5 * messageSize.height,
                                         __width,
                                         messageSize.height);
    self.textLabel = [[UILabel alloc] initWithFrame:messageLabelRect];
    self.textLabel.text = __text;
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.font = [UIFont systemFontOfSize:21.0];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.alpha = 1.0;
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    CGRect displayViewRect = CGRectMake(self.center.x - 0.5 * __width - DISPLAY_MESSAGE_XOFFEST,
                                        self.center.y - 0.5 * messageSize.height - DISPLAY_MESSAGE_YOFFEST,
                                        __width +  2.0 * DISPLAY_MESSAGE_XOFFEST,
                                        messageSize.height + 2 * DISPLAY_MESSAGE_YOFFEST);

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
        [self addViewsWithText:__text constrainedToWidth:__width];
    }
    return self;
}

@end
