//
//  TransitionGestureRecognizer.m
//  photio
//
//  Created by Troy Stribling on 3/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "TransitionGestureRecognizer.h"

#define DETECT_SWIPE_SPEED      400
#define MAX_DRAG_FACTOR         0.4f

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface TransitionGestureRecognizer ()

- (void)touched:(UIPanGestureRecognizer*)__recognizer;
- (void)delegateDrag:(CGPoint)__delta from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)delegateRelease:(CGPoint)__location;
- (void)delegateSwipe:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)delegateReachedMaxDrag:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (CGPoint)dragDelta:(CGPoint)__touchPoint;
- (void)determineDragDirection:(CGPoint)__velocity;
- (BOOL)detectedSwipe:(CGPoint)__velocity;
- (BOOL)detectedMaximumDrag;

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TransitionGestureRecognizer 

#pragma mark -
#pragma mark TransitionGestureRecognizer PrivateAPI

- (void)touched:(UIPanGestureRecognizer*)__recognizer {
    CGPoint velocity = [__recognizer velocityInView:self.relativeView];
    CGPoint touchPoint = [__recognizer locationInView:self.relativeView];
    CGPoint delta = [self dragDelta:touchPoint];
    switch (__recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self determineDragDirection:velocity];
            [self delegateDidStartDragging:touchPoint];
            self.totalDragDistance = CGPointMake(0.0, 0.0);
            self.lastTouch = touchPoint;
            self.acceptTouches = YES;
            break;
        case UIGestureRecognizerStateChanged:
            if (self.acceptTouches) {
                self.totalDragDistance = CGPointMake(self.totalDragDistance.x + delta.x, self.totalDragDistance.y + delta.y);
                [self detectedMaximumDrag] ? [self delegateReachedMaxDrag:delta from:touchPoint withVelocity:velocity] : [self delegateDrag:delta from:touchPoint withVelocity:velocity];
                self.lastTouch = CGPointMake(touchPoint.x, touchPoint.y);
            }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.acceptTouches) {
                [self detectedSwipe:velocity] ?  [self delegateSwipe:touchPoint withVelocity:velocity] : [self delegateRelease:touchPoint];
                self.acceptTouches = NO;
            }
            break;
        default:
            break;
    }
}

- (void)delegateDidStartDragging:(CGPoint)__location {
    switch (self.dragDirection) {
        case DragDirectionRight:
            if ([self.delegate respondsToSelector:@selector(didStartDraggingRight:)]) {
                [self.delegate didStartDraggingRight:__location];
            }
            break;
        case DragDirectionLeft:
            if ([self.delegate respondsToSelector:@selector(didStartDraggingLeft:)]) {
                [self.delegate didStartDraggingLeft:__location];
            }
            break;
        case DragDirectionUp:
            if ([self.delegate respondsToSelector:@selector(didStartDraggingUp:)]) {
                [self.delegate didStartDraggingUp:__location];
            }
            break;
        case DragDirectionDown:
            if ([self.delegate respondsToSelector:@selector(didStartDraggingDown:)]) {
                [self.delegate didStartDraggingDown:__location];
            }
            break;
    }
}

- (void)delegateDrag:(CGPoint)__delta from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    switch (self.dragDirection) {
        case DragDirectionRight:
            if ([self.delegate respondsToSelector:@selector(didDragRight:from:withVelocity:)]) {
                [self.delegate didDragRight:CGPointMake(__delta.x, 0.0) from:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionLeft:
            if ([self.delegate respondsToSelector:@selector(didDragLeft:from:withVelocity:)]) {
                [self.delegate didDragLeft:CGPointMake(__delta.x, 0.0) from:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionUp:
            if ([self.delegate respondsToSelector:@selector(didDragUp:from:withVelocity:)]) {
                [self.delegate didDragUp:CGPointMake(0.0, __delta.y) from:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionDown:
            if ([self.delegate respondsToSelector:@selector(didDragDown:from:withVelocity:)]) {
                [self.delegate didDragDown:CGPointMake(0.0, __delta.y) from:__location withVelocity:__velocity];
            }
            break;
    }
}

- (void)delegateRelease:(CGPoint)__location {
    switch (self.dragDirection) {
        case DragDirectionRight:
            if ([self.delegate respondsToSelector:@selector(didReleaseRight:)]) {
                [self.delegate didReleaseRight:__location];
            }
            break;
        case DragDirectionLeft:
            if ([self.delegate respondsToSelector:@selector(didReleaseLeft:)]) {
                [self.delegate didReleaseLeft:__location];
            }
            break;
        case DragDirectionUp:
            if ([self.delegate respondsToSelector:@selector(didReleaseUp:)]) {
                [self.delegate didReleaseUp:__location];
            }
            break;
        case DragDirectionDown:
            if ([self.delegate respondsToSelector:@selector(didReleaseDown:)]) {
                [self.delegate didReleaseDown:__location];
            }
            break;
    }    
}

- (void)delegateSwipe:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    switch (self.dragDirection) {
        case DragDirectionRight:
            if ([self.delegate respondsToSelector:@selector(didSwipeRight:withVelocity:)]) {
                [self.delegate didSwipeRight:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionLeft:
            if ([self.delegate respondsToSelector:@selector(didSwipeLeft:withVelocity:)]) {
                [self.delegate didSwipeLeft:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionUp:
            if ([self.delegate respondsToSelector:@selector(didSwipeUp:withVelocity:)]) {
                [self.delegate didSwipeUp:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionDown:
            if ([self.delegate respondsToSelector:@selector(didSwipeDown:withVelocity:)]) {
                [self.delegate didSwipeDown:__location withVelocity:__velocity];
            }
            break;
    }    
}

- (void)delegateReachedMaxDrag:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    switch (self.dragDirection) {
        case DragDirectionRight:
            if ([self.delegate respondsToSelector:@selector(didReachMaxDragRight:from:withVelocity:)]) {
                [self.delegate didReachMaxDragRight:__drag from:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionLeft:
            if ([self.delegate respondsToSelector:@selector(didReachMaxDragLeft:from:withVelocity:)]) {
                [self.delegate didReachMaxDragLeft:__drag from:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionUp:
            if ([self.delegate respondsToSelector:@selector(didReachMaxDragUp:from:withVelocity:)]) {
                [self.delegate didReachMaxDragUp:__drag from:__location withVelocity:__velocity];
            }
            break;
        case DragDirectionDown:
            if ([self.delegate respondsToSelector:@selector(didReachMaxDragDown:from:withVelocity:)]) {
                [self.delegate didReachMaxDragDown:__drag from:__location withVelocity:__velocity];
            }
            break;
    }    
}

- (CGPoint)dragDelta:(CGPoint)__touchPoint {
    CGFloat deltaX = __touchPoint.x - self.lastTouch.x;
    CGFloat deltaY = __touchPoint.y - self.lastTouch.y;
    return CGPointMake(deltaX, deltaY);
}

- (void)determineDragDirection:(CGPoint)__velocity {
    if (abs(__velocity.x) > abs(__velocity.y) && __velocity.x < 0) {
        self.dragDirection = DragDirectionLeft;        
    } else if (abs(__velocity.x) > abs(__velocity.y) && __velocity.x >= 0) {
        self.dragDirection = DragDirectionRight;        
    } else if (abs(__velocity.x) < abs(__velocity.y) && __velocity.y < 0) {
        self.dragDirection = DragDirectionUp;        
    } else {
        self.dragDirection = DragDirectionDown;                
    }
}

- (BOOL)detectedSwipe:(CGPoint)__velocity {
    BOOL swipeDetected = NO;
    switch (self.dragDirection) {
        case DragDirectionRight:
            if (__velocity.x > DETECT_SWIPE_SPEED) {
                swipeDetected = YES;
            }
            break;
        case DragDirectionLeft:
            if (-__velocity.x > DETECT_SWIPE_SPEED) {
                swipeDetected = YES;
            }
            break;
        case DragDirectionUp:
            if (-__velocity.y > DETECT_SWIPE_SPEED) {
                swipeDetected = YES;
            }
            break;
        case DragDirectionDown:
            if (__velocity.y > DETECT_SWIPE_SPEED) {
                swipeDetected = YES;
            }
            break;
    }
    return swipeDetected;
}

- (BOOL)detectedMaximumDrag {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    BOOL atMaximumDrag = YES;
    switch (self.dragDirection) {
        case DragDirectionRight:
        case DragDirectionLeft:
            if (abs(self.totalDragDistance.x) < screenBounds.size.width * MAX_DRAG_FACTOR) {
                atMaximumDrag = NO;
            }
            break;
        case DragDirectionUp:
        case DragDirectionDown:
            if (abs(self.totalDragDistance.y) < screenBounds.size.height * MAX_DRAG_FACTOR) {
                atMaximumDrag = NO;
            }
            break;
    }
    self.acceptTouches = atMaximumDrag ? NO : YES;
    return atMaximumDrag;
}

#pragma mark -
#pragma mark TransitionGestureRecognizer

+ (id)initWithDelegate:(id<TransitionGestureRecognizerDelegate>)__delegate inView:(UIView*)__view relativeToView:(UIView*)__relativeView {
    return [[self alloc] initWithDelegate:__delegate inView:__view relativeToView:(UIView*)__relativeView];
}

- (id)initWithDelegate:(id<TransitionGestureRecognizerDelegate>)__delegate inView:(UIView*)__view relativeToView:(UIView*)__relativeView {
    if (self = [super init]) {
        self.delegate = __delegate;
        self.view = __view;
        self.relativeView = __relativeView;
        self.gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(touched:)];
        [self.view addGestureRecognizer:self.gestureRecognizer];
        self.totalDragDistance = CGPointMake(0.0, 0.0);
        self.acceptTouches = NO;
    }
    return self;
}

- (BOOL)enabled {
    return self.gestureRecognizer.enabled;
}

- (void)enabled:(BOOL)__enabled {
    self.gestureRecognizer.enabled = __enabled;
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

@end
