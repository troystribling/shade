//
//  AnimateView.m
//  shade
//
//  Created by Troy Stribling on 3/24/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "AnimateView.h"

#define VIEW_SPACING                                    25.0f
#define HORIZONTAL_TRANSITION_ANIMATION_SPEED           500.0f
#define VERTICAL_TRANSITION_ANIMATION_SPEED             600.0f
#define RELEASE_ANIMATION_SPEED                         150.0f
#define HORIZONTAL_ANIMATION_SPEED                      500.0f
#define VERTICAL_ANIMATION_SPEED                        600.0f

static BOOL notAnimating    = YES;

@implementation AnimateView

#pragma mark -
#pragma mark Geometry

+ (CGRect)screenBounds {
    return [[UIScreen mainScreen] bounds];
}

+ (CGRect)inWindowRect {
    return [self screenBounds];
}

+ (CGRect)overWindowRect {
    CGRect screenBounds = [self screenBounds];
    return CGRectMake(screenBounds.origin.x, -screenBounds.size.height - VIEW_SPACING, screenBounds.size.width, screenBounds.size.height);
}

+ (CGRect)underWindowRect {
    CGRect screenBounds = [self screenBounds];
    return CGRectMake(screenBounds.origin.x, screenBounds.size.height + VIEW_SPACING, screenBounds.size.width, screenBounds.size.height);
}

+ (CGRect)leftOfWindowRect {
    CGRect screenBounds = [self screenBounds];
    return CGRectMake(-screenBounds.size.width - VIEW_SPACING, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height);
}

+ (CGRect)rightOfWindowRect {
    CGRect screenBounds = [self screenBounds];
    return CGRectMake(screenBounds.size.width + VIEW_SPACING, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height);
}

#pragma mark -
#pragma mark Animation Durations

+ (CGFloat)verticalReleaseDuration:(CGFloat)_offset  {
    return abs(_offset) / RELEASE_ANIMATION_SPEED;
}

+ (CGFloat)horizontaltReleaseDuration:(CGFloat)_offset  {
    return abs(_offset) / RELEASE_ANIMATION_SPEED;
}

+ (CGFloat)verticalTransitionDuration:(CGFloat)_offset {
    CGRect screenBounds = [self.class screenBounds];
    return (screenBounds.size.height - abs(_offset)) / VERTICAL_TRANSITION_ANIMATION_SPEED;
}

+ (CGFloat)horizontalTransitionDuration:(CGFloat)_offset {
    CGRect screenBounds = [self.class screenBounds];
    return (screenBounds.size.width  - abs(_offset)) / HORIZONTAL_TRANSITION_ANIMATION_SPEED;
}

+ (CGFloat)horizontalDuration:(CGFloat)__offset {
    return abs(__offset) / HORIZONTAL_ANIMATION_SPEED;
}

+ (CGFloat)verticalDuration:(CGFloat)__offset {
    return abs(__offset) / VERTICAL_ANIMATION_SPEED;
}

#pragma mark -
#pragma mark Animation

+ (void)drag:(CGPoint)__drag view:(UIView*)__view {
    if (notAnimating) {
        __view.transform = CGAffineTransformTranslate(__view.transform, __drag.x, __drag.y);
    }
}

+ (void)withDuration:(CGFloat)_duration andAnimation:(void(^)(void))_animation {
    [self withDuration:_duration animation:_animation onCompletion:nil];
}

+ (void)withDuration:(CGFloat)_duration animation:(void(^)(void))_animation onCompletion:(void(^)(void))__completion {
    if (notAnimating) {
        notAnimating = NO;
        [UIView animateWithDuration:_duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:_animation
                         completion:^(BOOL _finished){
                             notAnimating = YES;
                             if (__completion) {
                                 __completion();
                             }
                         }
         ];
    }
}

@end
