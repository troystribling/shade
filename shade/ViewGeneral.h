//
//  ViewGeneral.h
//  photio
//
//  Created by Troy Stribling on 2/22/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilteredCameraViewController.h"
#import "ImageInspectViewController.h"

@class ImageInspectViewController;
@class ProgressView;
@class Capture;

//-----------------------------------------------------------------------------------------------------------------------------------
@interface ViewGeneral : NSObject <FilteredCameraViewControllerDelegate, ImageInspectViewControllerDelegate> {
}

//-----------------------------------------------------------------------------------------------------------------------------------
@property(nonatomic, assign) BOOL                           notAnimating;
@property(nonatomic, strong) UIView*                        view;
@property(nonatomic, strong) ImageInspectViewController*    imageInspectViewController;
@property(nonatomic, strong) FilteredCameraViewController*  cameraViewController;
@property(nonatomic, strong) ProgressView*                  progressView;

//-----------------------------------------------------------------------------------------------------------------------------------
+ (ViewGeneral*)instance;
+ (CGRect)screenBounds;
+ (CGRect)inWindow;
+ (CGRect)overWindow;
+ (CGRect)underWindow;
+ (CGRect)leftOfWindow;
+ (CGRect)rightOfWindow;
+ (void)alertOnError:(NSError*)error;
+ (CGRect)imageThumbnailRect;

- (void)createViews:(UIView*)__containerView;
- (void)addCapture:(Capture*)__capture;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)showProgressViewWithMessage:(NSString*)__progressMessage;
- (void)removeProgressView;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)initImageInspectView:(UIView*)__containerView;
- (void)imageInspectViewPosition:(CGRect)__rec;
- (void)imageInspectViewHidden:(BOOL)__hidden;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)initCameraView:(UIView*)__containerView;
- (void)cameraViewPosition:(CGRect)__rec;
- (void)cameraViewHidden:(BOOL)__hidden;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)transitionCameraToInspectImage;
- (void)releaseCameraInspectImage;
- (void)dragCameraToInspectImage:(CGPoint)__drag;
- (void)releaseCamera;
- (void)dragCamera:(CGPoint)_drag;

@end
