//
//  CircleOfViews.m
//  shade
//
//  Created by Troy Stribling on 3/15/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "CircleOfViews.h"
#import "AnimateView.h"

@interface CircleOfViews ()

- (CGFloat)horizontalReleaseDuration;
- (CGFloat)horizontalTransitionDuration;
- (CGFloat)removeHorizontalDuration;
- (CGFloat)removeVerticalDuration;

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
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (NSInteger)count {
    return [self.circleOfViews count];
}

- (void)addView:(UIView*)__view {
    NSInteger viewCount = [self count];
    if (viewCount > 0) {
        self.rightViewCount++;
        __view.frame = [AnimateView rightOfWindowRect];
    } else {
        __view.frame = [AnimateView inWindowRect];
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

- (UIView*)displayedView {
    return [self.circleOfViews objectAtIndex:self.inViewIndex];
}

- (void)moveDisplayedViewDownAndRemove {
    [AnimateView withDuration:[self removeVerticalDuration]
                    animation:^{
                        [self displayedView].frame = [AnimateView underWindowRect];
                    }
                 onCompletion:^{
                     UIView* removedView = [self removeDisplayedView];
                     if (removedView) {
                         [self replaceRemovedView];
                     }
                 }
     ];
}

- (float)maximumDragFactor {
    return self.transitionGestureRecognizer.maximumDragFactor;
}

- (void)setMaximumDragFactor:(float)__maximumDragFactor {
    self.transitionGestureRecognizer.maximumDragFactor = __maximumDragFactor;
}

- (BOOL)enabled {
    return [self.transitionGestureRecognizer enabled];
}

- (void)enabled:(BOOL)_enabled {
    [self.transitionGestureRecognizer enabled:_enabled];
}

#pragma mark -
#pragma mark StackOfViews PrivateAPI

- (CGFloat)horizontalReleaseDuration  {
    UIView* viewItem = [self displayedView];
    return [AnimateView horizontaltReleaseDuration:viewItem.frame.origin.x];
}

- (CGFloat)horizontalTransitionDuration {
    UIView* viewItem = [self displayedView];
    return [AnimateView horizontalTransitionDuration:viewItem.frame.origin.x];
}

- (CGFloat)removeHorizontalDuration {
    return [AnimateView horizontalTransitionDuration:self.frame.size.width];
}

- (CGFloat)removeVerticalDuration {
    return [AnimateView horizontalTransitionDuration:self.frame.size.width];
}

- (void)dragView:(CGPoint)__drag {
    UIView* viewItem = [self displayedView];
    [AnimateView drag:__drag view:viewItem];
}

- (void)releaseView:(CGFloat)__duration onCompletion:(void(^)(void))__completetion {
    [AnimateView withDuration:__duration
                    animation:^{
                        [self displayedView].frame = [AnimateView inWindowRect];
                    }
                   onCompletion:__completetion
     ];
}

- (BOOL)canMoveRight {
    return [self.circleOfViews count] - 1 != self.rightViewCount;
}

- (BOOL)canMoveLeft {
    return self.rightViewCount != 0;
}

- (void)moveViewsLeft {
    [AnimateView withDuration:[self horizontalTransitionDuration]
                     animation:^{
                         [self nextRightView].frame = [AnimateView inWindowRect];
                         [self displayedView].frame = [AnimateView leftOfWindowRect];
                     }
                 onCompletion:^{
                     self.inViewIndex++;
                     self.rightViewCount--;
                     if ([self.delegate respondsToSelector:@selector(didMoveLeft)]) {
                         [self.delegate didMoveLeft];
                     }
                 }
     ];
}

- (void)moveViewsRight {
        [AnimateView withDuration:[self horizontalTransitionDuration]
                        animation:^{
                            [self nextLeftView].frame = [AnimateView inWindowRect];
                            [self displayedView].frame = [AnimateView rightOfWindowRect];
                        }
                     onCompletion:^{
                         self.inViewIndex--;
                         self.rightViewCount++;
                         if ([self.delegate respondsToSelector:@selector(didMoveRight)]) {
                             [self.delegate didMoveRight];
                         }
                     }
         ];
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
    [AnimateView withDuration:[self removeHorizontalDuration]
                     andAnimation:^{
                         [self displayedView].frame = [AnimateView inWindowRect];
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
