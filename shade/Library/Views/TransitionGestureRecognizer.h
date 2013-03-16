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

+ (id)initWithDelegate:(id<TransitionGestureRecognizerDelegate>)_delegate inView:(UIView*)__view relativeToView:(UIView*)__relativeView;
- (id)initWithDelegate:(id<TransitionGestureRecognizerDelegate>)__delegate inView:(UIView*)__view relativeToView:(UIView*)__relativeView;
- (BOOL)enabled;
- (void)enabled:(BOOL)__enabled;

@end


@protocol TransitionGestureRecognizerDelegate <NSObject>

@optional

- (void)didDragRight:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didDragLeft:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;

- (void)didStartDraggingRight:(CGPoint)__location;
- (void)didStartDraggingLeft:(CGPoint)__location;
- (void)didStartDraggingUp:(CGPoint)__location;
- (void)didStartDraggingDown:(CGPoint)__location;

- (void)didReleaseRight:(CGPoint)__location;
- (void)didReleaseLeft:(CGPoint)__location;
- (void)didReleaseUp:(CGPoint)__location;
- (void)didReleaseDown:(CGPoint)__location;

- (void)didSwipeRight:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didSwipeLeft:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)__velocity;

- (void)didReachMaxDragRight:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didReachMaxDragLeft:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didReachMaxDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didReachMaxDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;


@end