//
//  FilteredCameraViewController.h
//  photio
//
//  Created by Troy Stribling on 6/1/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitionGestureRecognizer.h"
#import "Camera+Extensions.h"
#import "CircleOfViews.h"

@interface FilteredCameraViewController : UIViewController <TransitionGestureRecognizerDelegate, CircleOfViewsDelegate>

@property(nonatomic, weak)      UIView*                                     containerView;
@property(nonatomic, strong)    IBOutlet UIGestureRecognizer*               captureImageGesture;
@property(nonatomic, strong)    UIView*                                     shutterView;
@property(nonatomic, assign)    CameraId                                    displayedCameraId;
@property(nonatomic, strong)    NSArray                                     *cameraIds;
@property(nonatomic, strong)    CircleOfViews                               *camerasCircleView;
@property(nonatomic, strong)    dispatch_queue_t                            cameraQueue;


+ (id)inView:(UIView*)__containerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inView:(UIView*)_containerView;

- (IBAction)captureStillImage:(id)__sender;

@end

