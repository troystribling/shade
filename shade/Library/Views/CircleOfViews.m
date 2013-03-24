//
//  CircleOfViews.m
//  shade
//
//  Created by Troy Stribling on 3/15/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "CircleOfViews.h"


@interface CircleOfViews ()

- (CGRect)inWindowRect;
- (CGRect)leftOfWindowRect;
- (CGRect)rightOfWindowRect;
- (CGRect)underWindowRect;

- (CGFloat)horizontalReleaseDuration;
- (CGFloat)horizontalTransitionDuration;
- (CGFloat)removeTransitionDuration;

- (void)dragView:(CGPoint)_drag;
- (void)releaseView:(CGFloat)_duration onCompletion:(void(^)(void))__completetion;

- (BOOL)canMoveRight;
- (BOOL)canMoveLeft;
- (void)moveViewsLeft;
- (void)moveViewsRight;
- (NSInteger)nextRightIndex;
- (NSInteger)nextLeftIndex;
- (UIView*)nextRightView;
- (UIView*)nextLeftView;
- (UIView*)nextLastRightView;
- (UIView*)nextLastLeftView;
- (void)insertViewAtBottomFromRight:(UIView*)__view;
- (void)insertViewAtBottomFromLeft:(UIView*)__view;

- (UIView*)removeDisplayedView;
- (void)replaceRemovedView;

@end

@implementation CircleOfViews

#pragma mark -
#pragma mark CircleOfViews

+ (id)withFrame:(CGRect)__frame delegate:(id<CircleOfViewsDelegate>)__delegate relativeToView:(UIView*)__relativeView {
    return [[CircleOfViews alloc] initWithFrame:__frame delegate:__delegate relativeToView:__relativeView];
}

- (id)initWithFrame:(CGRect)__frame delegate:(id<CircleOfViewsDelegate>)__delegate relativeToView:(UIView*)__relativeView {
    self = [super initWithFrame:__frame];
    if (self) {
        self.delegate = __delegate;
        self.transitionGestureRecognizer = [TransitionGestureRecognizer initWithDelegate:self inView:self relativeToView:__relativeView];
        self.circleOfViews = [NSMutableArray array];
        self.inViewIndex = 0;
        self.rightViewCount = 0;
        self.notAnimating = YES;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)addView:(UIView*)__view {
    NSInteger viewCount = [self count];
    if (viewCount > 0) {
        self.rightViewCount++;
        __view.frame = [self rightOfWindowRect];
    } else {
        __view.frame = [self inWindowRect];
    }
    [self addSubview:__view];
    [self.circleOfViews addObject:__view];
}

- (BOOL)hasView:(UIView*)__view {
    return [self.circleOfViews containsObject:__view];
}

- (void)removeView:(UIView*)__view {
    [self.circleOfViews removeObject:__view];
}

- (void)insertViewBelowTopView:(UIView*)__view {
    [self insertSubview:__view belowSubview:[self displayedView]];
}

- (UIView*)displayedView {
    return [self.circleOfViews objectAtIndex:self.inViewIndex];
}

- (void)moveDisplayedViewDownAndRemove {
    if (self.notAnimating) {
        self.notAnimating = NO;
        [UIView animateWithDuration:[self removeTransitionDuration]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self displayedView].frame = [self underWindowRect];
                         }
                         completion:^(BOOL _finished) {
                             UIView* removedView = [self removeDisplayedView];
                             if (removedView) {
                                 [self replaceRemovedView];
                             } else {
                                 self.notAnimating = YES;
                             }
                         }
         ];
    }
}

- (BOOL)enabled {
    return [self.transitionGestureRecognizer enabled];
}

- (void)enabled:(BOOL)_enabled {
    [self.transitionGestureRecognizer enabled:_enabled];
}

- (NSInteger)count {
    return [self.circleOfViews count];
}

- (float)maximumDragFactor {
    return self.transitionGestureRecognizer.maximumDragFactor;
}

- (void)setMaximumDragFactor:(float)__maximumDragFactor {
    self.transitionGestureRecognizer.maximumDragFactor = __maximumDragFactor;
}

#pragma mark -
#pragma mark StackOfViews PrivateAPI

- (CGRect)inWindowRect {
    return self.frame;
}

- (CGRect)leftOfWindowRect {
    return CGRectMake(-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGRect)rightOfWindowRect {
    return CGRectMake(self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGRect)underWindowRect {
    return CGRectMake(self.frame.origin.x, self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)horizontalReleaseDuration  {
    UIView* viewItem = [self displayedView];
    return abs(viewItem.frame.origin.x) / RELEASE_ANIMATION_SPEED;
}

- (CGFloat)horizontalTransitionDuration {
    UIView* viewItem = [self displayedView];
    return (self.frame.size.width - abs(viewItem.frame.origin.x)) / HORIZONTAL_TRANSITION_ANIMATION_SPEED;
}

- (CGFloat)removeTransitionDuration {
    return self.frame.size.width / HORIZONTAL_TRANSITION_ANIMATION_SPEED;
}

- (void)dragView:(CGPoint)_drag {
    if (self.notAnimating) {
        UIView* viewItem = [self displayedView];
        viewItem.transform = CGAffineTransformTranslate(viewItem.transform, _drag.x, _drag.y);
    }
}

- (void)releaseView:(CGFloat)_duration onCompletion:(void(^)(void))__completetion {
    if (self.notAnimating) {
        self.notAnimating = NO;
        [UIView animateWithDuration:_duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self displayedView].frame = [self inWindowRect];
                         }
                         completion:^(BOOL __finished){
                             if (__completetion) {
                                 __completetion();
                             }
                             self.notAnimating = YES;
                         }
         ];
    }
}

- (BOOL)canMoveRight {
    return [self.circleOfViews count] - 1 != self.rightViewCount;
}

- (BOOL)canMoveLeft {
    return self.rightViewCount != 0;
}

- (void)moveViewsLeft {
    if (self.notAnimating) {
        self.notAnimating = NO;
        [UIView animateWithDuration:[self horizontalTransitionDuration]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self nextRightView].frame = [self inWindowRect];
                             [self displayedView].frame = [self leftOfWindowRect];
                         }
                         completion:^(BOOL _finished) {
                             self.inViewIndex++;
                             self.rightViewCount--;
                             if ([self.delegate respondsToSelector:@selector(didMoveLeft)]) {
                                 [self.delegate didMoveLeft];
                             }
                             self.notAnimating = YES;
                         }
         ];
    }
}

- (void)moveViewsRight {
    if (self.notAnimating) {
        self.notAnimating = NO;
        [UIView animateWithDuration:[self horizontalTransitionDuration]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self nextLeftView].frame = [self inWindowRect];
                             [self displayedView].frame = [self rightOfWindowRect];
                         }
                         completion:^(BOOL _finished) {
                             self.inViewIndex--;
                             self.rightViewCount++;
                             if ([self.delegate respondsToSelector:@selector(didMoveRight)]) {
                                 [self.delegate didMoveRight];
                             }
                             self.notAnimating = YES;
                         }
         ];
    }
}

- (NSInteger)nextRightIndex {
    NSInteger nextIndex = self.inViewIndex + 1;
    if (nextIndex > [self.circleOfViews count] - 1) {
        nextIndex = 0;
    }
    return nextIndex;
}

- (NSInteger)nextLeftIndex {
    NSInteger nextIndex = self.inViewIndex - 1;
    if (nextIndex < 0) {
        nextIndex = [self.circleOfViews count] - 1;
    }
    return nextIndex;
}

- (UIView*)nextRightView {
    return [self.circleOfViews objectAtIndex:[self nextRightIndex]];
}

- (UIView*)nextLeftView {
    return [self.circleOfViews objectAtIndex:[self nextLeftIndex]];
}

- (UIView*)nextLastRightView {
    NSInteger viewIndex = self.inViewIndex - 1;
    if (self.inViewIndex == 0) {
        viewIndex = [self.circleOfViews count] - 1;
    }
    return [self.circleOfViews objectAtIndex:viewIndex];
}

- (UIView*)nextLastLeftView {
    NSInteger viewIndex = self.inViewIndex + 1;
    if (self.inViewIndex > [self.circleOfViews count]) {
        viewIndex = 0;
    }
    return [self.circleOfViews objectAtIndex:viewIndex];
}

- (void)insertViewAtBottomFromRight:(UIView*)__view {
    [self insertSubview:__view belowSubview:[self nextLastRightView]];
}

- (void)insertViewAtBottomFromLeft:(UIView*)__view {
    [self insertSubview:__view belowSubview:[self nextLastLeftView]];
}

- (UIView*)removeDisplayedView {
    UIView* viewToRemove = [self displayedView];
    [self.circleOfViews removeObject:viewToRemove];
    [viewToRemove removeFromSuperview];
    if ([self.circleOfViews count] == 0) {
        if ([self.delegate respondsToSelector:@selector(didRemoveAllViews)]) {
            [self.delegate didRemoveAllViews];
        }
        viewToRemove = nil;
    } else if (self.inViewIndex == [self.circleOfViews count] && self.inViewIndex != 0) {
        self.inViewIndex--;
    }
    return viewToRemove;
}

- (void)replaceRemovedView {
    self.notAnimating = NO;
    [UIView animateWithDuration:[self removeTransitionDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self displayedView].frame = [self inWindowRect];
                     }
                     completion:^(BOOL _finished) {
                         self.notAnimating = YES;
                     }
     ];    
}

#pragma mark -
#pragma mark TransitionGestureRecognizerDelegate

#pragma mark -
#pragma Right Gestures

- (void)didStartDraggingRight:(CGPoint)__location {
    if ([self.delegate respondsToSelector:@selector(didStartDraggingRight:)]) {
        [self.delegate didStartDraggingRight:__location];
    }
}

- (void)didDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [self dragView:_drag];
}

- (void)didReleaseRight:(CGPoint)_location {
    [self releaseView:[self horizontalReleaseDuration] onCompletion:^{
        if ([self.delegate respondsToSelector:@selector(didReleaseRight)]) {
            [self.delegate didReleaseRight];
        }
    }];
}

- (void)didReachMaxDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self canMoveRight]) {
        [self moveViewsRight];
    } else {
        [self releaseView:[self horizontalReleaseDuration] onCompletion:^{
            if ([self.delegate respondsToSelector:@selector(didReleaseRight)]) {
                [self.delegate didReleaseRight];
            }
        }];
    }
}

- (void)didSwipeRight:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self canMoveRight]) {
        [self moveViewsRight];
    } else {        
        [self releaseView:[self horizontalReleaseDuration] onCompletion:nil];
    }
}

#pragma mark -
#pragma Left Gestures

- (void)didStartDraggingLeft:(CGPoint)__location {
    if ([self.delegate respondsToSelector:@selector(didStartDraggingLeft:)]) {
        [self.delegate didStartDraggingLeft:__location];
    }
}

- (void)didDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [self dragView:_drag];
}

- (void)didReleaseLeft:(CGPoint)_location {
    [self releaseView:[self horizontalReleaseDuration] onCompletion:^{
        if ([self.delegate respondsToSelector:@selector(didReleaseLeft)]) {
            [self.delegate didReleaseLeft];
        }
    }];
}

- (void)didReachMaxDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self canMoveLeft]) {
        [self moveViewsLeft];
    } else {
        [self releaseView:[self horizontalReleaseDuration] onCompletion:^{
            if ([self.delegate respondsToSelector:@selector(didReleaseLeft)]) {
                [self.delegate didReleaseLeft];
            }
        }];
    }
}

- (void)didSwipeLeft:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self canMoveLeft]) {
        [self moveViewsLeft];
    } else {
        [self releaseView:[self horizontalReleaseDuration] onCompletion:nil];
    }
}

#pragma mark -
#pragma Up Gestures

- (void)didStartDraggingUp:(CGPoint)__location {
    if ([self.delegate respondsToSelector:@selector(didStartDraggingUp:)]) {
        [self.delegate didStartDraggingUp:__location];
    }
}

- (void)didDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(didDragUp:from:withVelocity:)]) {
        [self.delegate didDragUp:_drag from:_location withVelocity:_velocity];
    }
}

- (void)didReleaseUp:(CGPoint)_location {
    if ([self.delegate respondsToSelector:@selector(didReleaseUp:)]) {
        [self.delegate didReleaseUp:_location];
    }
}

- (void)didReachMaxDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(didReachMaxDragUp:from:withVelocity:)]) {
        [self.delegate didReachMaxDragUp:_drag from:_location withVelocity:_velocity];
    }
}

- (void)didSwipeUp:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(didSwipeUp:withVelocity:)]) {
        [self.delegate didSwipeUp:_location withVelocity:_velocity];
    }
}

#pragma mark -
#pragma Down Gestures

- (void)didStartDraggingDown:(CGPoint)__location {
    if ([self.delegate respondsToSelector:@selector(didStartDraggingDown:)]) {
        [self.delegate didStartDraggingDown:__location];
    }
}

- (void)didDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(didDragDown:from:withVelocity:)]) {
        [self.delegate didDragDown:_drag from:_location withVelocity:_velocity];
    }
}

- (void)didReleaseDown:(CGPoint)_location {
    if ([self.delegate respondsToSelector:@selector(didReleaseDown:)]) {
        [self.delegate didReleaseDown:_location];
    }
}

- (void)didReachMaxDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(didReachMaxDragDown:from:withVelocity:)]) {
        [self.delegate didReachMaxDragDown:_drag from:_location withVelocity:_velocity];
    }
}

- (void)didSwipeDown:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(didSwipeDown:withVelocity:)]) {
        [self.delegate didSwipeDown:_location withVelocity:_velocity];
    }
}

@end
