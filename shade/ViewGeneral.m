//
//  ViewGeneral.m
//  photio
//
//  Created by Troy Stribling on 2/22/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ViewGeneral.h"
#import "UIImage+Resize.h"
#import "ImageDisplay.h"

#import "ImageEditViewController.h"
#import "ProgressView.h"

#define HORIZONTAL_TRANSITION_ANIMATION_SPEED           500.0f
#define VERTICAL_TRANSITION_ANIMATION_SPEED             600.0f
#define RELEASE_ANIMATION_SPEED                         150.0f
#define VIEW_MIN_SPACING                                25
#define SAVE_IMAGE_DELAY                                0.65f
#define OPEN_SHUTTER_TRANSITION                         0.25
#define OPEN_SHUTTER_DELAY                              1.0
#define MAX_COMMENT_LINES                               5
#define COMMENT_YOFFSET                                 15


/////////////////////////////////////////////////////////////////////////////////////////
static ViewGeneral* thisViewControllerGeneral = nil;

/////////////////////////////////////////////////////////////////////////////////////////
@interface ViewGeneral (PrivateAPI)

- (void)transition:(CGFloat)_duration withAnimation:(void(^)(void))_animation;
- (void)drag:(CGPoint)_drag view:(UIView*)_view;
- (CGFloat)verticalReleaseDuration:(CGFloat)_offset;
- (CGFloat)horizontaltReleaseDuration:(CGFloat)_offset;
- (CGFloat)verticalTransitionDuration:(CGFloat)_offset;
- (CGFloat)horizontalTransitionDuration:(CGFloat)_offset;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@implementation ViewGeneral
 
#pragma mark -
#pragma mark ViewGeneral PrivateAPI

- (void)transition:(CGFloat)_duration withAnimation:(void(^)(void))_animation {
    if (self.notAnimating) {
        self.notAnimating = NO;
        [UIView animateWithDuration:_duration
            delay:0
            options:UIViewAnimationOptionCurveEaseOut
            animations:_animation
            completion:^(BOOL _finished){
                self.notAnimating = YES;
            }
        ];
    }
}

- (void)drag:(CGPoint)_drag view:(UIView*)_view {
    if (self.notAnimating) {
        _view.transform = CGAffineTransformTranslate(_view.transform, _drag.x, _drag.y);
    }
}

- (CGFloat)verticalReleaseDuration:(CGFloat)_offset  {
    return abs(_offset) / RELEASE_ANIMATION_SPEED;    
}

- (CGFloat)horizontaltReleaseDuration:(CGFloat)_offset  {
    return abs(_offset) / RELEASE_ANIMATION_SPEED;    
}

- (CGFloat)verticalTransitionDuration:(CGFloat)_offset {
    CGRect screenBounds = [self.class screenBounds];
    return (screenBounds.size.height - abs(_offset)) / VERTICAL_TRANSITION_ANIMATION_SPEED;    
}

- (CGFloat)horizontalTransitionDuration:(CGFloat)_offset {
    CGRect screenBounds = [self.class screenBounds];
    return (screenBounds.size.width  - abs(_offset)) / HORIZONTAL_TRANSITION_ANIMATION_SPEED;    
}

#pragma mark - 
#pragma mark ViewGeneral

+ (ViewGeneral*)instance {	
    @synchronized(self) {
        if (thisViewControllerGeneral == nil) {
            thisViewControllerGeneral = [[self alloc] init]; 
            thisViewControllerGeneral.notAnimating = YES;
        }
    }
    return thisViewControllerGeneral;
}

+ (CGRect)screenBounds {
    return [[UIScreen mainScreen] bounds];
}

+ (CGRect)inWindow {
    return [self screenBounds];
}

+ (CGRect)overWindow {
    CGRect screenBounds = [self screenBounds];
    return CGRectMake(screenBounds.origin.x, -screenBounds.size.height - VIEW_MIN_SPACING, screenBounds.size.width, screenBounds.size.height);
}

+ (CGRect)underWindow {
    CGRect screenBounds = [self screenBounds];
    return CGRectMake(screenBounds.origin.x, screenBounds.size.height + VIEW_MIN_SPACING, screenBounds.size.width, screenBounds.size.height);
}

+ (CGRect)leftOfWindow {
    CGRect screenBounds = [self screenBounds];
    return CGRectMake(-screenBounds.size.width - VIEW_MIN_SPACING, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height);
}

+ (CGRect)rightOfWindow {
    CGRect screenBounds = [self screenBounds];
    return CGRectMake(screenBounds.size.width + VIEW_MIN_SPACING, screenBounds.origin.y, screenBounds.size.width, screenBounds.size.height);
}

+ (void)alertOnError:(NSError*)error {
    NSLog(@"Had and Error %@, %@", error, [error userInfo]);
    [[[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil] show];    
}

+ (CGRect)imageThumbnailRect {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width / THUMBNAILS_IN_ROW;
    return CGRectMake(0.0, 0.0, width, width);
}

- (void)createViews:(UIView*)__view {
    self.view = __view;
    [self initImageInspectView:__view];
    [self initCameraView:__view];
}

- (void)updateCalendarEntryWithDate:(NSDate*)_date {
    [self.calendarViewController updateEntryWithDate:_date];
}

- (void)addCapture:(UIImage*)__capture {
    [self.imageInspectViewController addCapture:__capture];
}

#pragma mark - 
#pragma mark ProgressView

- (void)showProgressViewWithMessage:(NSString*)__progressMessage {
    if (self.progressView == nil) {
        self.progressView = [ProgressView progressView];
    }
    [self.progressView progressWithMessage:_progressMessage inView:self.containerView];
}

- (void)removeProgressView {
    [self.progressView remove]; 
}

#pragma mark - 
#pragma mark ImageInspectViewController

- (void)initImageInspectView:(UIView*)__view {
    if (self.imageInspectViewController == nil) {
        self.imageInspectViewController = [ImageInspectViewController inView:_containerView withDelegate:self];
    } 
    [self imageInspectViewPosition:[self.class overWindow]];
    [_containerView addSubview:self.imageInspectViewController.view];
}

- (void)imageInspectViewHidden:(BOOL)__hidden {
    self.imageInspectViewController.view.hidden = _hidden;
}

- (void)imageInspectViewPosition:(CGRect)__rect {
    self.imageInspectViewController.view.frame = _rect;
}

#pragma mark - 
#pragma mark CameraViewController

- (void)initCameraView:(UIView*)__view {
    if (self.cameraViewController == nil) {
        self.cameraViewController = [FilteredCameraViewController inView:__view];
    } 
    [self cameraViewPosition:[self.class inWindow]];
    self.cameraViewController.delegate = self;
    [__view addSubview:self.cameraViewController.view];
}

- (void)cameraViewHidden:(BOOL)__hidden {
    self.cameraViewController.view.hidden = __hidden;
}

- (void)cameraViewPosition:(CGRect)__rect {
    self.cameraViewController.view.frame = __rect;
}

#pragma mark - 
#pragma mark Camera To Inspect Image

- (void)transitionCameraToInspectImage {
    if ([self.imageInspectViewController hasCaptures]) {
        [self transition:[self verticalTransitionDuration:self.cameraViewController.view.frame.origin.y] withAnimation:^{
                [self cameraViewPosition:[self.class underWindow]];
                [self imageInspectViewPosition:[self.class inWindow]];
            }
        ];
    }
}

- (void)releaseCameraInspectImage {
    [self transition:[self horizontaltReleaseDuration:self.cameraViewController.view.frame.origin.y] withAnimation:^{
        [self cameraViewPosition:[self.class inWindow]];
    }
     ];    
}

- (void)dragCameraToInspectImage:(CGPoint)__drag {
    if ([self.imageInspectViewController hasCaptures]) {
        [self drag:__drag view:self.cameraViewController.view];
    }
}

#pragma mark -
#pragma mark ImageInspectViewControllerDelegate

- (void)dragInspectImage:(CGPoint)__drag {
    [self drag:__drag view:self.imageInspectViewController.view];
}

- (void)releaseInspectImage {
    [self transition:[self verticalReleaseDuration:self.imageInspectViewController.view.frame.origin.y] withAnimation:^{
            [self imageInspectViewPosition:[self.class inWindow]];
        }
    ];    
}

- (void)transitionFromInspectImage {
    [self transition:[self verticalTransitionDuration:self.imageInspectViewController.view.frame.origin.y] withAnimation:^{
            [self cameraViewPosition:[self.class inWindow]];
            [self imageInspectViewPosition:[self.class overWindow]];
        }
    ];    
}


@end
