//
//  FilteredCameraViewController.m
//  photio
//
//  Created by Troy Stribling on 6/1/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "FilteredCameraViewController.h"
#import "ParameterSliderView.h"
#import "Capture+Extensions.h"
#import "ViewGeneral.h"
#import "CameraFactory.h"
#import "DataManager.h"

#define CAMERA_SHUTTER_TRANSITION     0.2f
#define CAMERA_SHUTTER_DELAY          1.5f
#define CAMERA_CONTROLS_TRANSITION    0.2f

@interface FilteredCameraViewController ()

- (void)openShutter;
- (void)closeShutter;
- (void)openShutterOnStart;

@end

@implementation FilteredCameraViewController

#pragma mark -
#pragma mark FilteredCameraViewController PrivateAPI

- (void)closeShutter {
    self.shutterView.alpha = 0.0;
    [self.view addSubview:self.shutterView];
    [UIView animateWithDuration:CAMERA_SHUTTER_TRANSITION
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
             self.shutterView.alpha = 1.0;
        }
        completion:^(BOOL _finished){
        }
    ];
}

- (void)openShutter {
    [UIView animateWithDuration:CAMERA_SHUTTER_TRANSITION 
        delay:0.0 
        options:UIViewAnimationOptionCurveEaseOut 
        animations:^{
            self.shutterView.alpha = 0.0;
        }
        completion:^(BOOL _finished) {
           [self.shutterView removeFromSuperview];
        }
    ];
}
- (void)openShutterOnStart {
    self.shutterView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.shutterView.backgroundColor = [UIColor blackColor];
    self.shutterView.alpha = 1.0;
    [UIView animateWithDuration:CAMERA_SHUTTER_TRANSITION
        delay:CAMERA_SHUTTER_DELAY
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
             self.shutterView.alpha = 0.0;
        }
        completion:^(BOOL _finished) {
            [self.shutterView removeFromSuperview];
        }
    ];
}

#pragma mark -
#pragma mark FilteredCameraViewController

+ (id)inView:(UIView*)__containerView {
    return [[FilteredCameraViewController alloc] initWithNibName:@"FilteredCameraViewController" bundle:nil inView:__containerView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inView:(UIView*)__containerView {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.containerView = __containerView;
        self.transitionGestureRecognizer = [TransitionGestureRecognizer initWithDelegate:self inView:self.view relativeToView:self.containerView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self openShutterOnStart];
    GPUImageView* gpuImageView = (GPUImageView*)self.view;
    gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    CameraFactory *cameraFactory = [CameraFactory instance];
    self.displayedCameraId = [cameraFactory defaultCameraId];
    [cameraFactory activateCameraWithId:self.displayedCameraId forView:(GPUImageView*)self.view];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)captureStillImage:(id)__sender {
    self.captureImageGesture.enabled = NO;
    [self closeShutter];
    [[CameraFactory instance] captureStillImageForCameraWithId:self.displayedCameraId onCompletion:^(NSData* imageData, NSError* error) {
        if (error) {
            [ViewGeneral alertOnError:error];
        }
        else {
            UIImage* capturedImage = [[UIImage alloc] initWithData:imageData];
            Capture *capture = [Capture create];
            [capture save];
            ViewGeneral *viewGeneral = [ViewGeneral instance];
            [viewGeneral addCapture:capture andImage:capturedImage];
            [viewGeneral writeImage:capturedImage withId:[capture imageID]];
        }
        self.captureImageGesture.enabled = YES;
        [self openShutter];
    }];
}

#pragma mark -
#pragma mark TransitionGestureRecognizerDelegate

- (void)didDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
}

- (void)didDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {    
}

- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
}

- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] dragCameraToInspectImage:__drag];
}

- (void)didReleaseRight:(CGPoint)__location {
    [[ViewGeneral instance] releaseCamera];
}

- (void)didReleaseLeft:(CGPoint)__location {
    [[ViewGeneral instance] releaseCamera];
}

- (void)didReleaseUp:(CGPoint)__location {
}

- (void)didReleaseDown:(CGPoint)__location {
    [[ViewGeneral instance] releaseCameraInspectImage];
}

- (void)didSwipeRight:(CGPoint)__location withVelocity:(CGPoint)__velocity {
}

- (void)didSwipeLeft:(CGPoint)__location withVelocity:(CGPoint)__velocity {
}

- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[CameraFactory instance] rotateCameraWithCameraId:self.displayedCameraId];
}

- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

- (void)didReachMaxDragRight:(CGPoint)_drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
}

- (void)didReachMaxDragLeft:(CGPoint)_drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {    
}

- (void)didReachMaxDragUp:(CGPoint)_drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {    
    [[CameraFactory instance] rotateCameraWithCameraId:self.displayedCameraId];
}

- (void)didReachMaxDragDown:(CGPoint)_drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {    
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

@end
