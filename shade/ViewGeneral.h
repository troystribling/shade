//
//  ViewGeneral.h
//  photio
//
//  Created by Troy Stribling on 2/22/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageInspectViewController;
@class FilteredCameraViewController;
@class ProgressView;
@class Capture;
@class ImageEntryView;

//-----------------------------------------------------------------------------------------------------------------------------------
@interface ViewGeneral : NSObject {
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

- (void)createViews:(UIView*)__containerView;
- (void)addCapture:(Capture*)__capture andImageData:(NSData*)__imageData;
- (void)addCapture:(Capture*)__capture andImage:(UIImage*)__image;
- (void)writeImage:(NSData*)__image withId:(NSString*)__fileId onCompletion:(void(^)(BOOL __status))__completion;
- (UIImage*)readImageWithId:(NSString*)__fileId;
- (void)deleteImageWithId:(NSString*)__fileId;
- (void)drag:(CGPoint)_drag view:(UIView*)_view;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)showProgressViewWithMessage:(NSString*)__progressMessage;
- (void)removeProgressView;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)createImageInspectView:(UIView*)__containerView;
- (void)imageInspectViewPosition:(CGRect)__rec;
- (void)imageInspectViewHidden:(BOOL)__hidden;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)createCameraView:(UIView*)__containerView;
- (void)cameraViewPosition:(CGRect)__rec;
- (void)cameraViewHidden:(BOOL)__hidden;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)transitionCameraToInspectImage;
- (void)releaseCameraInspectImage;
- (void)dragCameraToInspectImage:(CGPoint)__drag;
- (void)releaseCamera;
- (void)dragCamera:(CGPoint)_drag;

//-----------------------------------------------------------------------------------------------------------------------------------
- (void)dragInspectImageToCamera:(CGPoint)__drag;
- (void)releaseInspectImageToCamera;
- (void)transitionInspectImageToCamera;

@end
