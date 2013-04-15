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

- (void)dragView:(CGPoint)_drag;
- (void)releaseView:(CGFloat)_duration onCompletion:(void(^)(void))__completetion;

- (NSInteger)rightViewCount;
- (BOOL)canMoveRight;
- (BOOL)canMoveLeft;
- (void)moveViewsLeft;
- (void)moveViewsRight;

- (BOOL)migrateViewsRightIfNeeded;
- (BOOL)migrateViewsLeftIfNeeded;

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
        self.nextLastViewIndex = 0;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (NSInteger)count {
    return [self.circleOfViews count];
}

- (void)addView:(UIView*)__view {
    NSInteger viewCount = [self count];
    if (self.inViewIndex < self.nextLastViewIndex || self.inViewIndex == 0) {
        if (viewCount > 0) {
            __view.frame = [AnimateView rightOfWindowRect];
        } else {
            __view.frame = [AnimateView inWindowRect];
        }
    } else {
        __view.frame = [AnimateView leftOfWindowRect];
        self.inViewIndex++;
    }
    [self.circleOfViews insertObject:__view atIndex:self.nextLastViewIndex];
    self.nextLastViewIndex++;
    [self addSubview:__view];
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

- (UIView*)removeDisplayedView {
    UIView* viewToRemove = [self displayedView];
    [self.circleOfViews removeObject:viewToRemove];
    [viewToRemove removeFromSuperview];
    if ([self.circleOfViews count] == 0) {
        if ([self.delegate respondsToSelector:@selector(didRemoveAllViews)]) {
            [self.delegate didRemoveAllViews];
        }
    } else if (self.inViewIndex == [self.circleOfViews count] && self.inViewIndex != 0) {
        self.inViewIndex--;
    }
    if (self.nextLastViewIndex > 0) {
        self.nextLastViewIndex--;
    }
    return viewToRemove;
}

- (void)replaceRemovedView {
    if ([self count] > 0) {
        [self displayedView].frame = [AnimateView inWindowRect];
    }
}

- (float)maximumDragFactor {
    return self.transitionGestureRecognizer.maximumDragFactor;
}

- (void)setMaximumDragFactor:(float)__maximumDragFactor {
    self.transitionGestureRecognizer.maximumDragFactor = __maximumDragFactor;
}

- (BOOL)touchEnabled {
    return [self.transitionGestureRecognizer enabled];
}

- (void)touchEnabled:(BOOL)_enabled {
    [self.transitionGestureRecognizer enabled:_enabled];
}

- (void)hideLeftViews:(BOOL)__hidden {
    for (int i = 0; i < self.inViewIndex; i++) {
        UIView *leftView = [self.circleOfViews objectAtIndex:i];
        leftView.hidden = __hidden;
    }
}

- (void)hideRightViews:(BOOL)__hidden {
    for (int i = self.inViewIndex; i < [self.circleOfViews count] - 1; i++) {
        UIView *rightView = [self.circleOfViews objectAtIndex:i];
        rightView.hidden = __hidden;
    }
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

- (NSInteger)rightViewCount {
    return [self count] - self.inViewIndex - 1;
}

- (BOOL)canMoveRight {
    return [self count] - 1 != [self rightViewCount];
}

- (BOOL)canMoveLeft {
    return [self rightViewCount] != 0;
}

- (void)moveViewsLeft {
    [AnimateView withDuration:[self horizontalTransitionDuration]
                     animation:^{
                         [self nextRightView].frame = [AnimateView inWindowRect];
                         [self displayedView].frame = [AnimateView leftOfWindowRect];
                     }
                 onCompletion:^{
                     self.inViewIndex++;
                     [self migrateViewsRightIfNeeded];
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
                         [self migrateViewsLeftIfNeeded];
                         if ([self.delegate respondsToSelector:@selector(didMoveRight)]) {
                             [self.delegate didMoveRight];
                         }
                     }
         ];
}

- (BOOL)migrateViewsRightIfNeeded {
    BOOL status = NO;
    if ([self.circleOfViews count] > 1) {
        if ([self rightViewCount] == 0) {
            status = YES;
            UIView *migrationView = [self.circleOfViews objectAtIndex:0];
            migrationView.frame = [AnimateView rightOfWindowRect];
            [self.circleOfViews removeObject:migrationView];
            [self.circleOfViews addObject:migrationView];
            if (self.inViewIndex > 0) {
                self.inViewIndex--;
            } else {
                self.inViewIndex = [self count] - 1;
            }
            if (self.nextLastViewIndex > 1) {
                self.nextLastViewIndex--;
            } else {
                self.nextLastViewIndex = [self count];
            }
        }
    }
    return status;
}

- (BOOL)migrateViewsLeftIfNeeded {
    BOOL status = NO;
    if ([self.circleOfViews count] > 1) {
        NSInteger leftViewCount = self.inViewIndex;
        if (leftViewCount == 0) {
            status = YES;
            UIView *migrationView = [self.circleOfViews lastObject];
            migrationView.frame = [AnimateView leftOfWindowRect];
            [self.circleOfViews removeObject:migrationView];
            [self.circleOfViews insertObject:migrationView atIndex:0];
            if (self.inViewIndex < [self count] - 1) {
                self.inViewIndex++;
            } else {
                self.inViewIndex = 0;
            }
            if (self.nextLastViewIndex < [self count]) {
                self.nextLastViewIndex++;
            } else {
                self.nextLastViewIndex = 1;
            }
        }
    }
    return status;
}

#pragma mark -
#pragma mark TransitionGestureRecognizerDelegate

#pragma mark -
#pragma Right Gestures

- (void)didStartDraggingRight:(CGPoint)__location {
    [self migrateViewsLeftIfNeeded];
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
    [self migrateViewsRightIfNeeded];
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
