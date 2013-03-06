//
//  FilteredCameraViewController.m
//  photio
//
//  Created by Troy Stribling on 6/1/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "FilteredCameraViewController.h"
#import "ParameterSliderView.h"
#import "ViewGeneral.h"
#import "CameraFactory.h"

#define CAMERA_SHUTTER_TRANSITION     0.2f
#define CAMERA_SHUTTER_DELAY          1.5f
#define CAMERA_CONTROLS_TRANSITION    0.2f

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface FilteredCameraViewController ()

- (void)setCamera:(Camera*)__camera;
- (void)openShutter;
- (void)closeShutter;
- (void)openShutterOnStart;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation FilteredCameraViewController

#pragma mark -
#pragma mark FilteredCameraViewController PrivateAPI

- (IBAction)captureStillImage:(id)__sender {
    self.captureImageGesture.enabled = NO;
    [self closeShutter];
    [[CameraFactory instance] captureStillImage:^(NSData* imageData, NSError* error) {
        if (error) {
            [ViewGeneral alertOnError:error];
        }
        else {
            UIImage* capturedImage = [[UIImage alloc] initWithData:imageData];
            [[CaptureManager instance] createCaptureInBackgroundForImage:capturedImage];
        }             
        [[CaptureManager instance] waitForCaptureImageQueue];
        self.captureImageGesture.enabled = YES;
        [self openShutter];
    }];
}

- (void)setCamera:(Camera*)__camera {
    [[CameraFactory instance] setCamera:__camera forView:(GPUImageView*)self.view];
}

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
    [self setCamera:[[CameraFactory instance] defaultCamera]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark TransitionGestureRecognizerDelegate

- (void)didDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [[ViewGeneral instance] dragCamera:_drag];    
}

- (void)didDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
    [[ViewGeneral instance] dragCamera:_drag];    
}

- (void)didDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
}

- (void)didDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [[ViewGeneral instance] dragCameraToInspectImage:_drag];
}

- (void)didReleaseRight:(CGPoint)_location {
    [[ViewGeneral instance] releaseCamera];
}

- (void)didReleaseLeft:(CGPoint)_location {
    [[ViewGeneral instance] releaseCamera];
}

- (void)didReleaseUp:(CGPoint)_location {
}

- (void)didReleaseDown:(CGPoint)_location {
    [[ViewGeneral instance] releaseCameraInspectImage];
}

- (void)didSwipeRight:(CGPoint)_location withVelocity:(CGPoint)_velocity {
}

- (void)didSwipeLeft:(CGPoint)_location withVelocity:(CGPoint)_velocity {
}

- (void)didSwipeUp:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [[CameraFactory instance].stillCamera rotateCamera];
}

- (void)didSwipeDown:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

- (void)didReachMaxDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
}

- (void)didReachMaxDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
}

- (void)didReachMaxDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
}

- (void)didReachMaxDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

@end
