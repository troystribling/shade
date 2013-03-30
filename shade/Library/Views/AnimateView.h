//
//  AnimateView.h
//  shade
//
//  Created by Troy Stribling on 3/24/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimateView : NSObject

+ (CGRect)screenBounds;
+ (CGRect)inWindowRect;
+ (CGRect)overWindowRect;
+ (CGRect)underWindowRect;
+ (CGRect)leftOfWindowRect;
+ (CGRect)rightOfWindowRect;

+ (CGFloat)verticalReleaseDuration:(CGFloat)__offset;
+ (CGFloat)horizontaltReleaseDuration:(CGFloat)__offset;
+ (CGFloat)verticalTransitionDuration:(CGFloat)__offset withSpeed:(CGFloat)__speed;
+ (CGFloat)verticalTransitionDuration:(CGFloat)__offset;
+ (CGFloat)horizontalTransitionDuration:(CGFloat)__offset;
+ (CGFloat)horizontalDuration:(CGFloat)__offset;
+ (CGFloat)verticalDuration:(CGFloat)__offset;

+ (void)drag:(CGPoint)__drag view:(UIView*)__view;
+ (void)withDuration:(CGFloat)_duration andAnimation:(void(^)(void))_animation;
+ (void)withDuration:(CGFloat)_duration animation:(void(^)(void))_animation onCompletion:(void(^)(void))__completion;

@end
