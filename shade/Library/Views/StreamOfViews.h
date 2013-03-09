//
//  StreamOfViews.h
//  photio
//
//  Created by Troy Stribling on 3/25/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitionGestureRecognizer.h"

@protocol StreamOfViewsDelegate;

@interface StreamOfViews : UIView <TransitionGestureRecognizerDelegate> {
}

@property (nonatomic, weak)    id<StreamOfViewsDelegate>        delegate;
@property (nonatomic, strong)  TransitionGestureRecognizer*     transitionGestureRecognizer;
@property (nonatomic, strong)  NSMutableArray*                  streamOfViews;
@property (nonatomic, assign)  NSInteger                        inViewIndex;
@property (nonatomic, assign)  BOOL                             notAnimating;

+ (id)withFrame:(CGRect)_frame delegate:(id<StreamOfViewsDelegate>)_delegate relativeToView:(UIView*)_relativeView;
- (id)initWithFrame:(CGRect)_frame delegate:(id<StreamOfViewsDelegate>)_delegate relativeToView:(UIView*)_relativeView;
- (void)addViewToRight:(UIView*)_view;
- (void)addViewToLeft:(UIView*)_view;
- (void)removeFirstView;
- (void)removeLastView;
- (UIView*)displayedView;
- (void)moveDisplayedViewDownAndRemove;
- (void)moveDisplayedViewDiagonallyAndRemove;
- (void)reset;
- (BOOL)enabled;
- (void)enabled:(BOOL)_enabled;
- (NSInteger)count;

@end

@protocol StreamOfViewsDelegate <NSObject>

@required

@optional

- (void)didDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didReleaseUp:(CGPoint)_location;
- (void)didSwipeUp:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didReachMaxDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didReleaseDown:(CGPoint)_location;
- (void)didSwipeDown:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didReachMaxDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity;
- (void)didRemoveAllViews;
- (void)didMoveRight;
- (void)didMoveLeft;

@end
