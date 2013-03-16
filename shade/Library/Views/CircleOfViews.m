//
//  CircleOfViews.m
//  shade
//
//  Created by Troy Stribling on 3/15/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "CircleOfViews.h"

@interface CircleOfViews ()

- (void)dragView:(CGPoint)_drag;
- (BOOL)canMove;
- (void)moveViewBelowTopView:(UIView*)__view;

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

- (void)dragView:(CGPoint)_drag {
    if (self.notAnimating) {
        UIView* viewItem = [self displayedView];
        viewItem.transform = CGAffineTransformTranslate(viewItem.transform, _drag.x, _drag.y);
    }
}

- (BOOL)canMove {
    return [self.circleOfViews count] > 1;
}

- (void)moveViewBelowTopView:(UIView*)__view {
    [self insertSubview:__view belowSubview:[self displayedView]];
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
}

- (void)didReachMaxDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
}

- (void)didSwipeRight:(CGPoint)_location withVelocity:(CGPoint)_velocity {
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
}

- (void)didReachMaxDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
}


- (void)didSwipeLeft:(CGPoint)_location withVelocity:(CGPoint)_velocity {
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
