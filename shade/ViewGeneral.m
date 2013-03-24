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
#import "AnimateView.h"

static ViewGeneral* thisViewControllerGeneral = nil;

@interface ViewGeneral ()

+ (NSString*)imageFilenameForID:(NSString*)__fileId;

@end

@implementation ViewGeneral
 
#pragma mark -
#pragma mark ViewGeneral PrivateAPI


+ (NSString*)imageFilenameForID:(NSString*)__fileId {
    return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png", __fileId]];
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
    }
    return self;
}

- (void)createViews:(UIView*)__view {
    self.view = __view;
    [self createImageInspectView:__view];
    [self createCameraView:__view];
}

- (void)addCapture:(Capture*)__capture andImageData:(NSData *)__imageData {
    [self.imageInspectViewController addCapture:__capture andImageData:__imageData];
}

- (void)addCapture:(Capture*)__capture andImage:(UIImage*)__image {
    [self.imageInspectViewController addCapture:__capture andImage:__image];
}

- (void)writeImage:(NSData*)__image withId:(NSString*)__fileId  onCompletion:(void(^)(BOOL __status))__completion {
    dispatch_queue_t saveImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(saveImageQueue, ^{
        BOOL status = [__image writeToFile:[self.class imageFilenameForID:__fileId] atomically:YES];
        if (__completion) {
            __completion(status);
        }
    });
}

- (UIImage*)readImageWithId:(NSString*)__fileId {
    NSString *imageFilename = [self.class imageFilenameForID:__fileId];
    UIImage *image = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilename]) {
        image = [UIImage imageWithContentsOfFile:imageFilename];
    }
    return image;
}

- (void)deleteImageWithId:(NSString*)__fileId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* filename = [self.class imageFilenameForID:__fileId];
    if ([fileManager fileExistsAtPath:filename]) {
        NSError *error;
        [fileManager removeItemAtPath:filename error:&error];
        if (error) {
            [UIAlertView alertOnError:error];
        }
    }
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
    self.progressView = nil;
}

#pragma mark - 
#pragma mark ImageInspectViewController

- (void)createImageInspectView:(UIView*)__view {
    if (self.imageInspectViewController == nil) {
        self.imageInspectViewController = [ImageInspectViewController inView:__view];
    } 
    [self imageInspectViewPosition:[AnimateView overWindowRect]];
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
    [self cameraViewPosition:[AnimateView inWindowRect]];
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
        [AnimateView withDuration:[AnimateView verticalTransitionDuration:self.cameraViewController.view.frame.origin.y] andAnimation:^{
                [self cameraViewPosition:[AnimateView underWindowRect]];
                [self imageInspectViewPosition:[AnimateView inWindowRect]];
            }
        ];
    }
}

- (void)releaseCameraInspectImage {
    [AnimateView withDuration:[AnimateView horizontaltReleaseDuration:self.cameraViewController.view.frame.origin.y] andAnimation:^{
            [self cameraViewPosition:[AnimateView inWindowRect]];
        }
     ];
}

- (void)dragCameraToInspectImage:(CGPoint)__drag {
    if ([self.imageInspectViewController hasCaptures]) {
        [AnimateView drag:__drag view:self.cameraViewController.view];
    }
}

- (void)releaseCamera {
    [AnimateView withDuration:[self.class horizontaltReleaseDuration:self.cameraViewController.view.frame.origin.x] andAnimation:^{
        [self cameraViewPosition:[AnimateView inWindowRect]];
    }];
}

- (void)dragCamera:(CGPoint)_drag {
    [AnimateView drag:_drag view:self.cameraViewController.view];
}

#pragma mark -
#pragma mark ImageInspectViewControllerDelegate

- (void)dragInspectImageToCamera:(CGPoint)__drag {
    [AnimateView drag:__drag view:self.imageInspectViewController.view];
}

- (void)releaseInspectImageToCamera {
    [AnimateView withDuration:[AnimateView verticalReleaseDuration:self.imageInspectViewController.view.frame.origin.y] andAnimation:^{
            [self imageInspectViewPosition:[AnimateView inWindowRect]];
        }
    ];    
}

- (void)transitionInspectImageToCamera {
    [AnimateView withDuration:[AnimateView verticalTransitionDuration:self.imageInspectViewController.view.frame.origin.y] andAnimation:^{
            [self cameraViewPosition:[AnimateView inWindowRect]];
            [self imageInspectViewPosition:[AnimateView overWindowRect]];
        }
    ];    
}

@end
