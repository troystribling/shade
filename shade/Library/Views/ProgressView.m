//
//  ProgressView.m
//  photio
//
//  Created by Troy Stribling on 5/14/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "ProgressView.h"
#import "RoundedCornersView.h"

#define DISPLAY_MESSAGE_XOFFEST     15.0
#define DISPLAY_MESSAGE_YOFFEST     10.0
#define DISPLAY_MESSAGE_WIDTH       200.0
#define DISPLAY_REMOVE_DURATION     0.5

@interface ProgressView ()

- (void)addDisplayView:(NSString*)_displayMessage;

@end

@implementation ProgressView

@synthesize displayView, backgroundView, displayMessage;

+ (id)progressView {
    return [[ProgressView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)progressWithMessage:(NSString*)_progressMessage inView:(UIView*)_containerView {
    [self addDisplayView:_progressMessage];
    [_containerView addSubview:self];
}

- (void)remove {
    [UIView animateWithDuration:DISPLAY_REMOVE_DURATION 
         animations:^{
             self.alpha = 0.0;
         } 
         completion:^(BOOL _finished) {
             [self removeFromSuperview];
             self.alpha = 1.0;
         }
     ];
}

- (id)initWithFrame:(CGRect)_frame {
    self = [super initWithFrame:_frame];
    if (self) {
        self.backgroundView = [[UIView alloc] initWithFrame:_frame];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 0.6;
        [self addSubview:self.backgroundView];
    }
    return self;
}

- (void)addDisplayView:(NSString*)_displayMessage {
    CGSize messageSize = [_displayMessage sizeWithFont:[UIFont systemFontOfSize:21.0] constrainedToSize:CGSizeMake(DISPLAY_MESSAGE_WIDTH, self.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect messageLabelRect = CGRectMake(self.center.x - 0.5 * DISPLAY_MESSAGE_WIDTH, 
                                         self.center.y - 0.5 * messageSize.height, 
                                         DISPLAY_MESSAGE_WIDTH, 
                                         messageSize.height);
    CGRect displayViewRect = CGRectMake(self.center.x - 0.5 * DISPLAY_MESSAGE_WIDTH - DISPLAY_MESSAGE_XOFFEST, 
                                        self.center.y - 0.5 * messageSize.height - DISPLAY_MESSAGE_YOFFEST, 
                                        DISPLAY_MESSAGE_WIDTH +  2.0 * DISPLAY_MESSAGE_XOFFEST,
                                        messageSize.height + 2 * DISPLAY_MESSAGE_YOFFEST);
    self.displayMessage = [[UILabel alloc] initWithFrame:messageLabelRect];
    self.displayMessage.text = _displayMessage;
    self.displayMessage.textColor = [UIColor whiteColor];
    self.displayMessage.font = [UIFont systemFontOfSize:21.0];
    self.displayMessage.backgroundColor = [UIColor clearColor];
    self.displayMessage.alpha = 1.0;
    self.displayMessage.numberOfLines = 0;
    self.displayMessage.textAlignment = NSTextAlignmentCenter;
    self.displayMessage.lineBreakMode = NSLineBreakByWordWrapping;
    self.displayView = [RoundedCornersView withFrame:displayViewRect];
    self.displayView.alpha = .8;
    self.displayView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.displayView];
    [self addSubview:self.displayMessage];
}

@end
