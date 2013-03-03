//
//  FilteredCameraViewController.h
//  photio
//
//  Created by Troy Stribling on 6/1/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitionGestureRecognizer.h"

@protocol FilteredCameraViewControllerDelegate;

@class Camera;

@interface FilteredCameraViewController : UIViewController <TransitionGestureRecognizerDelegate>

@property(nonatomic, weak)      UIView*                                     containerView;
@property(nonatomic, weak)      id<FilteredCameraViewControllerDelegate>    delegate;
@property(nonatomic, strong)    IBOutlet UIGestureRecognizer*               captureImageGesture;
@property(nonatomic, strong)    TransitionGestureRecognizer*                transitionGestureRecognizer;
@property(nonatomic, strong)    UIView*                                     shutterView;

+ (id)inView:(UIView*)__containerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inView:(UIView*)_containerView;

- (IBAction)captureStillImage:(id)__sender;
- (IBAction)changeCamera:(id)__sender;

@end

@protocol FilteredCameraViewControllerDelegate <NSObject>

@end
