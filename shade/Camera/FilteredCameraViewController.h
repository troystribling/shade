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
#import "StreamOfViews.h"

@class StreamOfViews;

@interface FilteredCameraViewController : UIViewController <TransitionGestureRecognizerDelegate, StreamOfViewsDelegate>

@property(nonatomic, weak)      UIView*                                     containerView;
@property(nonatomic, strong)    IBOutlet UIGestureRecognizer*               captureImageGesture;
@property(nonatomic, strong)    UIView*                                     shutterView;
@property(nonatomic, assign)    CameraId                                    displayedCameraId;
@property(nonatomic, strong)    StreamOfViews                               *camerasStreamView;


+ (id)inView:(UIView*)__containerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inView:(UIView*)_containerView;

- (IBAction)captureStillImage:(id)__sender;

@end

