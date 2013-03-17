//
//  CircleOfViews.m
//  shade
//
//  Created by Troy Stribling on 3/15/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "CircleOfViews.h"

#define HORIZONTAL_TRANSITION_ANIMATION_SPEED           750.0f
#define FADE_TRANSITION_DURATUION                       0.5f
#define RELEASE_ANIMATION_SPEED                         400.0f
#define VIEW_MIN_SPACING                                25
#define REMOVE_DISPLAYED_VIEW_DOWN_DURATION             0.5

@interface CircleOfViews ()

- (CGRect)inWindowRect;
- (CGRect)rightOfWindowRect;
- (CGRect)leftOfWindowRect;
- (void)dragView:(CGPoint)_drag;
- (void)releaseView:(CGFloat)_duration;
- (BOOL)canMove;
- (CGFloat)horizontalReleaseDuration;
- (CGFloat)horizontalTransitionDuration;
- (CGFloat)removeTransitionDuration;
- (void)moveViewsLeft;
- (void)moveViewsRight;
- (NSInteger)nextRightIndex;
- (NSInteger)nextLeftIndex;
- (UIView*)nextRightView;
- (UIView*)nextLeftView;

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
        self.notAnimating = YES;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)addViewToTop:(UIView*)__view {
    if ([self count] > 0) {
        [[self displayedView] removeFromSuperview];
    }
    __view.frame = self.frame;
    [self addSubview:__view];
    [self.circleOfViews insertObject:__view atIndex:0];
}

- (void)addViewToBottom:(UIView*)__view {
    __view.frame = self.frame;
    [self.circleOfViews addObject:__view];
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

- (void)dragView:(CGPoint)_drag {
    if (self.notAnimating) {
        UIView* viewItem = [self displayedView];
        viewItem.transform = CGAffineTransformTranslate(viewItem.transform, _drag.x, _drag.y);
    }
}

- (void)releaseView:(CGFloat)_duration {
    if (self.notAnimating) {
        self.notAnimating = NO;
        [UIView animateWithDuration:_duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self displayedView].frame = [self inWindowRect];
                         }
                         completion:^(BOOL _finished){
                             self.notAnimating = YES;
                         }
         ];
    }
}

- (BOOL)canMove {
    return [self.circleOfViews count] > 1;
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

- (void)moveViewsLeft {
    if (([self canMove] && self.notAnimating)) {
        self.notAnimating = NO;
        [self enabled:NO];
        [UIView animateWithDuration:[self horizontalTransitionDuration]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self displayedView].frame = [self leftOfWindowRect];
                         }
                         completion:^(BOOL _finished) {
                             [[self displayedView] removeFromSuperview];
                             [self displayedView].frame = [self inWindowRect];
                             self.inViewIndex = [self nextLeftIndex];
                             if ([self.delegate respondsToSelector:@selector(didMoveLeft)]) {
                                 [self.delegate didMoveLeft];
                             }
                             self.notAnimating = YES;
                             [self enabled:YES];
                         }
         ];
    }
}

- (void)moveViewsRight {    
    if (([self canMove] && self.notAnimating)) {
        self.notAnimating = NO;
        [self enabled:NO];
        [UIView animateWithDuration:[self horizontalTransitionDuration]
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self displayedView].frame = [self rightOfWindowRect];
                         }
                         completion:^(BOOL _finished) {
                             [[self displayedView] removeFromSuperview];
                             [self displayedView].frame = [self inWindowRect];
                             self.inViewIndex = [self nextRightIndex];
                             if ([self.delegate respondsToSelector:@selector(didMoveLeft)]) {
                                 [self.delegate didMoveRight];
                             }
                             self.notAnimating = YES;
                             [self enabled:YES];
                         }
         ];
    }
}

- (NSInteger)nextRightIndex {
    NSInteger nextIndex = self.inViewIndex - 1;
    if (nextIndex < 0) {
        nextIndex = [self.circleOfViews count] - 1;
    }
    return nextIndex;
}

- (NSInteger)nextLeftIndex {
    NSInteger nextIndex = self.inViewIndex + 1;
    if (nextIndex > [self.circleOfViews count] - 1) {
        nextIndex = 0;
    }
    return nextIndex;
}

- (UIView*)nextRightView {
    return [self.circleOfViews objectAtIndex:[self nextRightIndex]];
}

- (UIView*)nextLeftView {
    return [self.circleOfViews objectAtIndex:[self nextLeftIndex]];
}

#pragma mark -
#pragma mark TransitionGestureRecognizerDelegate

#pragma mark -
#pragma Right Gestures

- (void)didStartDraggingRight:(CGPoint)__location {
    if ([self.circleOfViews count] == 1) {
        if ([self.delegate respondsToSelector:@selector(didStartDraggingRight:)]) {
            [self.delegate didStartDraggingRight:__location];
        }
    } else {
        [self insertViewBelowTopView:[self nextLeftView]];
    }
}

- (void)didDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [self dragView:_drag];
}

- (void)didReleaseRight:(CGPoint)_location {
    [self releaseView:[self horizontalReleaseDuration]];
}

- (void)didReachMaxDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self canMove]) {
        [self moveViewsRight];
    } else {
        [self releaseView:[self horizontalReleaseDuration]];
    }
}

- (void)didSwipeRight:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [self moveViewsRight];
}

#pragma mark -
#pragma Left Gestures

- (void)didStartDraggingLeft:(CGPoint)__location {
    if ([self.circleOfViews count] == 1) {
        if ([self.delegate respondsToSelector:@selector(didStartDraggingLeft:)]) {
            [self.delegate didStartDraggingLeft:__location];
        }
    } else {
        [self insertViewBelowTopView:[self nextRightView]];
    }
}

- (void)didDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [self dragView:_drag];
}

- (void)didReleaseLeft:(CGPoint)_location {
    [self releaseView:[self horizontalReleaseDuration]];
}

- (void)didReachMaxDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self canMove]) {
        [self moveViewsLeft];
    } else {
        [self releaseView:[self horizontalReleaseDuration]];
    }
}


- (void)didSwipeLeft:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [self moveViewsLeft];
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
        [self.delegate didStartDraggingUp:__location];
    }
}

- (void)didDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(didStartDraggingDown:)]) {
        [self.delegate didStartDraggingDown:_location];
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
