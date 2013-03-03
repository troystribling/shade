//
//  FilteredCameraViewController.h
//  photio
//
//  Created by Troy Stribling on 6/1/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParameterSelectionView.h"
#import "TransitionGestureRecognizer.h"
#import "ParameterSliderView.h"

@protocol FilteredCameraViewControllerDelegate;

@class ParameterSliderView;
@class Camera;

@interface FilteredCameraViewController : UIViewController <TransitionGestureRecognizerDelegate, ParameterSelectionViewDelegate, ParameterSliderViewDelegate>

@property(nonatomic, weak)      UIView*                                     containerView;
@property(nonatomic, weak)      id<FilteredCameraViewControllerDelegate>    delegate;
@property(nonatomic, strong)    ParameterSelectionView*                     cameraSelectionView;
@property(nonatomic, strong)    IBOutlet UIGestureRecognizer*               captureImageGesture;
@property(nonatomic, strong)    IBOutlet UIView*                            cameraControlsView;
@property(nonatomic, strong)    IBOutlet UIView*                            cameraConfigView;
@property(nonatomic, strong)    IBOutlet UIImageView*                       selectedCameraView;
@property(nonatomic, strong)    IBOutlet UIImageView*                       cameraAutoAdjustView;
@property(nonatomic, strong)    IBOutlet ParameterSliderView*               cameraParameterView;
@property(nonatomic, strong)    TransitionGestureRecognizer*                transitionGestureRecognizer;
@property(nonatomic, strong)    UIView*                                     shutterView;
@property(nonatomic, assign)    BOOL                                        cameraConfigIsShown;

+ (id)inView:(UIView*)_containerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inView:(UIView*)_containerView;

@end

@protocol FilteredCameraViewControllerDelegate <NSObject>

@end
