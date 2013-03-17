//
//  CircleOfViews.h
//  shade
//
//  Created by Troy Stribling on 3/15/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransitionGestureRecognizer.h"

@protocol CircleOfViewsDelegate;

@interface CircleOfViews : UIView <TransitionGestureRecognizerDelegate> {
}

@property (nonatomic, weak)    id<CircleOfViewsDelegate>        delegate;
@property (nonatomic, strong)  TransitionGestureRecognizer*     transitionGestureRecognizer;
@property (nonatomic, strong)  NSMutableArray*                  circleOfViews;
@property (nonatomic, assign)  NSInteger                        inViewIndex;
@property (nonatomic, assign)  BOOL                             notAnimating;

+ (id)withFrame:(CGRect)__frame delegate:(id<CircleOfViewsDelegate>)__delegate relativeToView:(UIView*)__relativeView;
- (id)initWithFrame:(CGRect)__frame delegate:(id<CircleOfViewsDelegate>)__delegate relativeToView:(UIView*)__relativeView;
- (void)addViewToTop:(UIView*)__view;
- (void)addViewToBottom:(UIView*)__view;
- (void)insertViewBelowTopView:(UIView*)__view;
- (UIView*)displayedView;
- (void)moveDisplayedViewDownAndRemove;
- (BOOL)enabled;
- (void)enabled:(BOOL)__enabled;
- (NSInteger)count;

@end

@protocol CircleOfViewsDelegate <NSObject>

@required

@optional

- (void)didStartDraggingUp:(CGPoint)__location;
- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didReleaseUp:(CGPoint)__location;
- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)_velocity;
- (void)didReachMaxDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;

- (void)didStartDraggingDown:(CGPoint)__location;
- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;
- (void)didReleaseDown:(CGPoint)__location;
- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)_velocity;
- (void)didReachMaxDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity;

- (void)didStartDraggingRight:(CGPoint)__location;
- (void)didStartDraggingLeft:(CGPoint)__location;

- (void)didMoveLeft;
- (void)didMoveRight;
- (void)didRemoveAllViews;

@end
