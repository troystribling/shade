//
//  TransitionGestureRecognizer.h
//  photio
//
//  Created by Troy Stribling on 3/2/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DragDirectionRight,
    DragDirectionLeft,
    DragDirectionUp,
    DragDirectionDown
} DragDirection;

@protocol TransitionGestureRecognizerDelegate;

@interface TransitionGestureRecognizer : NSObject {
}

@property (nonatomic, weak)   id<TransitionGestureRecognizerDelegate>   delegate;
@property (nonatomic, weak)   UIView*                                   view;
@property (nonatomic, weak)   UIView*                                   relativeView;
@property (nonatomic, strong) UIPanGestureRecognizer*                   gestureRecognizer;
@property (nonatomic, assign) CGPoint                                   lastTouch;
@property (nonatomic, assign) CGPoint                                   totalDragDistance;
@property (nonatomic, assign) DragDirection                             dragDirection;
@property (nonatomic, assign) BOOL                                      acceptTouches;

+ (id)initWithDelegate:(id<TransitionGestureRecognizerDelegate>)_delegate inView:(UIView*)_view relativeToView:(UIView*)_relativeView;
- (id)initWithDelegate:(id<TransitionGestureRecognizerDelegate>)_delegate inView:(UIView*)_view relativeToView:(UIView*)_relativeView;
- (BOOL)enabled;
- (void)enabled:(BOOL)_enabled;

@end


@protocol TransitionGestureRecognizerDelegate <NSObject>

@optional

- (void)didDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;

- (void)didReleaseRight:(CGPoint)_location;
- (void)didReleaseLeft:(CGPoint)_location;
- (void)didReleaseUp:(CGPoint)_location;
- (void)didReleaseDown:(CGPoint)_location;

- (void)didSwipeRight:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didSwipeLeft:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didSwipeUp:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didSwipeDown:(CGPoint)_location withVelocity:(CGPoint)_velocity;

- (void)didReachMaxDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didReachMaxDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didReachMaxDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didReachMaxDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;


@end