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
#import "UIImage+Extensions.h"
#import "FilteredCameraViewController.h"
#import "ImageInspectViewController.h"
#import "UIAlertView+Extensions.h"
#import "ImageEntryView.h"
#import "ProgressView.h"

#define HORIZONTAL_TRANSITION_ANIMATION_SPEED           500.0f
#define VERTICAL_TRANSITION_ANIMATION_SPEED             600.0f
#define RELEASE_ANIMATION_SPEED                         150.0f
#define VIEW_MIN_SPACING                                25
#define MAX_PENDING_IMAGE_SAVES                         5

/////////////////////////////////////////////////////////////////////////////////////////
static ViewGeneral* thisViewControllerGeneral = nil;

/////////////////////////////////////////////////////////////////////////////////////////
@interface ViewGeneral ()

- (void)transition:(CGFloat)_duration withAnimation:(void(^)(void))_animation;
- (void)drag:(CGPoint)_drag view:(UIView*)_view;
- (CGFloat)verticalReleaseDuration:(CGFloat)_offset;
- (CGFloat)horizontaltReleaseDuration:(CGFloat)_offset;
- (CGFloat)verticalTransitionDuration:(CGFloat)_offset;
- (CGFloat)horizontalTransitionDuration:(CGFloat)_offset;
+ (NSString*)imageFilenameForID:(NSString*)__fileId;

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

- (void)drag:(CGPoint)__drag view:(UIView*)__view {
    if (self.notAnimating) {
        __view.transform = CGAffineTransformTranslate(__view.transform, __drag.x, __drag.y);
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

+ (NSString*)imageFilenameForID:(NSString*)__fileId {
    return [NSString stringWithFormat:@"Documents/%@.png", __fileId];
}

#pragma mark - 
#pragma mark ViewGeneral

+ (ViewGeneral*)instance {	
    @synchronized(self) {
        if (thisViewControllerGeneral == nil) {
            thisViewControllerGeneral = [[self alloc] init]; 
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
    [[[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                message:[error localizedFailureReason]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                      otherButtonTitles:nil] show];
}

- (id)init {
    self = [super init];
    if (self) {
        self.notAnimating = YES;
        self.saveImageQueue = dispatch_queue_create("com.imaginaryproducts.shade", NULL);
    }
    return self;
}

- (void)createViews:(UIView*)__view {
    self.view = __view;
    [self createImageInspectView:__view];
    [self createCameraView:__view];
}

- (void)addCapture:(Capture*)__capture andImage:(UIImage *)__image {
    [self.imageInspectViewController addCapture:__capture andImage:__image];
}

- (void)writeImage:(UIImage*)__image withId:(NSString*)__fileId {
    dispatch_async(self.saveImageQueue, ^{
        NSData* image = UIImagePNGRepresentation(__image);
        [image writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:[self.class imageFilenameForID:__fileId]] atomically:YES];
    });
}

- (UIImage*)readImageWithId:(NSString*)__fileId {
    return [UIImage imageWithContentsOfFile:[self.class imageFilenameForID:__fileId]];
}

- (void)deleteImageWithId:(NSString*)__fileId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* filename = [self.class imageFilenameForID:__fileId];
    if ([fileManager fileExistsAtPath:filename]) {
        [self showProgressViewWithMessage:@"Deleting"];
        NSError *error;
        [fileManager removeItemAtPath:filename error:&error];
        [self removeProgressView];
        if (error) {
            [UIAlertView alertOnError:error];
        }
    }
}

- (void)finishedSavingImageEntryToCameraRoll:(UIImage*)_image didFinishSavingWithError:(NSError*)__error contextInfo:(void*)__context {
    [self removeProgressView];
    if (__error) {
        [UIAlertView alertOnError:__error];
    }
}

- (void)saveImageEntryToCameraRoll:(ImageEntryView*)__entry {
    [self showProgressViewWithMessage:@"Saving to Camera Roll"];
    UIImageWriteToSavedPhotosAlbum(__entry.image, self, @selector(finishedSavingImageEntryToCameraRoll:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark - 
#pragma mark ProgressView

- (void)showProgressViewWithMessage:(NSString*)__progressMessage {
    if (self.progressView == nil) {
        self.progressView = [ProgressView progressView];
    }
    [self.progressView progressWithMessage:__progressMessage inView:self.view];
}

- (void)removeProgressView {
    [self.progressView remove]; 
}

#pragma mark - 
#pragma mark ImageInspectViewController

- (void)createImageInspectView:(UIView*)__view {
    if (self.imageInspectViewController == nil) {
        self.imageInspectViewController = [ImageInspectViewController inView:__view];
    } 
    [self imageInspectViewPosition:[self.class overWindow]];
    [__view addSubview:self.imageInspectViewController.view];
}

- (void)imageInspectViewHidden:(BOOL)__hidden {
    self.imageInspectViewController.view.hidden = __hidden;
}

- (void)imageInspectViewPosition:(CGRect)__rect {
    self.imageInspectViewController.view.frame = __rect;
}

#pragma mark - 
#pragma mark CameraViewController

- (void)createCameraView:(UIView*)__view {
    if (self.cameraViewController == nil) {
        self.cameraViewController = [FilteredCameraViewController inView:__view];
    } 
    [self cameraViewPosition:[self.class inWindow]];
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

- (void)releaseCamera {
    [self transition:[self horizontaltReleaseDuration:self.cameraViewController.view.frame.origin.x] withAnimation:^{
        [self cameraViewPosition:[self.class inWindow]];
    }];
}

- (void)dragCamera:(CGPoint)_drag {
    [self drag:_drag view:self.cameraViewController.view];
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

- (void)transitionInspectImageToCamera {
    [self transition:[self verticalTransitionDuration:self.imageInspectViewController.view.frame.origin.y] withAnimation:^{
            [self cameraViewPosition:[self.class inWindow]];
            [self imageInspectViewPosition:[self.class overWindow]];
        }
    ];    
}

@end
