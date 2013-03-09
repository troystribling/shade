//
//  DiagonalGestureRecognizer.m
//  photio
//
//  Created by Troy Stribling on 4/11/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "DiagonalGestureRecognizer.h"

#define DETECT_DIAGONAL_SWIPE_MIN_SLOPE       0.25
#define DETECT_DIAGONAL_SWIPE_MAX_SLOPE       8.0

@interface DiagonalGestureRecognizer ()

- (BOOL)diagonalSwipeFor:(CGFloat)_deltaX and:(CGFloat)_deltaY;
- (void)diagonalStateInit;
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event;

@end

@implementation DiagonalGestureRecognizer

@synthesize gestureDelegate, strokeUp, midPoint, diagonalSwipe, firstTouch; 

#pragma mark -
#pragma mark DiagonalGestureRecognizer

+ (id)initWithDelegate:(id<DiagonalGestureRecognizerDelegate>)_checkDelegate {
    return [[DiagonalGestureRecognizer alloc] initWithDelegate:_checkDelegate];
}

- (id)initWithDelegate:(id<DiagonalGestureRecognizerDelegate>)_gestureDelegate {
    if (self = [super init]) {
        self.gestureDelegate = _gestureDelegate;
        [self diagonalStateInit];
    }
    return self;
}

#pragma mark -
#pragma mark DiagonalGestureRecognizer PrivateAPI

- (BOOL)diagonalSwipeFor:(CGFloat)_deltaX and:(CGFloat)_deltaY {
    if (!self.diagonalSwipe) {
        CGFloat slope = (_deltaY / _deltaX);
        if (slope > DETECT_DIAGONAL_SWIPE_MIN_SLOPE && slope < DETECT_DIAGONAL_SWIPE_MAX_SLOPE) {
            self.diagonalSwipe = YES;
        }
    }
    return self.diagonalSwipe;
}

- (void)diagonalStateInit {
    self.midPoint = CGPointZero;
    self.strokeUp = NO;
    self.diagonalSwipe = NO;
    self.firstTouch = YES;
}

#pragma mark -
#pragma mark UIGestureRecognizer

- (void)reset {
    [super reset];
    [self diagonalStateInit];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self diagonalStateInit];
    if ([touches count] != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    CGFloat deltaX = nowPoint.x - prevPoint.x;
    CGFloat deltaY = nowPoint.y - prevPoint.y;
    if (self.firstTouch) {
        [self diagonalSwipeFor:deltaX and:deltaY];
        self.firstTouch = NO;
    }
    if (self.diagonalSwipe) {
        if (!self.strokeUp) {
            if (fabsf(deltaX) > 0.0 && deltaY > 0.0) {
                self.midPoint = nowPoint;
            } else if (deltaX >= 0.0 && deltaY <= 0.0) {
                strokeUp = YES;
            } else {
                self.state = UIGestureRecognizerStateFailed;
            }
        }
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.state == UIGestureRecognizerStatePossible) {
        if (self.strokeUp) {
            if ([self.gestureDelegate respondsToSelector:@selector(didCheck)]) {
                [self.gestureDelegate didCheck];
            }
        } else if (self.diagonalSwipe) {
            if ([self.gestureDelegate respondsToSelector:@selector(didDiagonalSwipe)]) {
                [self.gestureDelegate didDiagonalSwipe];
            }
        }
        self.state = UIGestureRecognizerStateRecognized;
    }
    [self diagonalStateInit];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self diagonalStateInit];
    self.state = UIGestureRecognizerStateFailed;
}

@end
