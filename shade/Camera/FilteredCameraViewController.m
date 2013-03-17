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
- (void)animateShutterToAlpha:(float)__alpha onCompletion:(void(^)(void))__completion;
- (void)openShutterOnStart;
- (void)addCameraWithID:(CameraId)__cameraID;

@end

@implementation FilteredCameraViewController

#pragma mark -
#pragma mark FilteredCameraViewController PrivateAPI

- (void)animateShutterToAlpha:(float)__alpha onCompletion:(void(^)(void))__completion {
    [UIView animateWithDuration:CAMERA_SHUTTER_TRANSITION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.shutterView.alpha = __alpha;
                     }
                     completion:^(BOOL _finished){
                         if (__completion) {
                             __completion();
                         }
                     }
    ];
}

- (void)closeShutter {
    self.shutterView.alpha = 0.0;
    [self.view addSubview:self.shutterView];
    [self animateShutterToAlpha:1.0f onCompletion:nil];
}

- (void)openShutter {
    [self animateShutterToAlpha:1.0f onCompletion:^{
        [self.shutterView removeFromSuperview];
    }];
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

- (void)addCameraWithID:(CameraId)__cameraID {
    GPUImageView* gpuImageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    if ([self.camerasCircleView count] == 0) {
        [self.camerasCircleView addViewToTop:gpuImageView];
    } else {
        [self.camerasCircleView addViewToBottom:gpuImageView];
        [self.camerasCircleView insertViewBelowTopView:gpuImageView];
    }
    [[CameraFactory instance] activateCameraWithId:__cameraID forView:gpuImageView];
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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.camerasCircleView = [CircleOfViews withFrame:self.view.frame delegate:self relativeToView:self.containerView];
    [self.view addSubview:self.camerasCircleView];
    [self openShutterOnStart];
    self.displayedCameraId = [[CameraFactory instance] defaultCameraId];
    [self addCameraWithID:self.displayedCameraId];
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
#pragma mark CircleOfViewsDelegate

- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] dragCameraToInspectImage:__drag];
}

- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
}

- (void)didReleaseUp:(CGPoint)_location {
}

- (void)didReleaseDown:(CGPoint)__location {
    [[ViewGeneral instance] releaseCameraInspectImage];
}

- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[CameraFactory instance] rotateCameraWithCameraId:self.displayedCameraId];
}

- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

- (void)didReachMaxDragUp:(CGPoint)__drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
    [[CameraFactory instance] rotateCameraWithCameraId:self.displayedCameraId];
}

- (void)didReachMaxDragDown:(CGPoint)__drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

- (void)didRemoveAllViews {
    [[ViewGeneral instance] transitionInspectImageToCamera];
}

- (void)didStartDraggingRight:(CGPoint)__location {
    [self addCameraWithID:[[CameraFactory instance] nextRightCameraIdRelativeTo:self.displayedCameraId]];
}

- (void)didStartDraggingLeft:(CGPoint)__location {
    [self addCameraWithID:[[CameraFactory instance] nextLeftCameraIdRelativeTo:self.displayedCameraId]];
}

- (void)didMoveLeft {
}

- (void)didMoveRight {
}

@end
