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
#import "CaptureManager.h"

#define CAMERA_SHUTTER_TRANSITION     0.2f
#define CAMERA_SHUTTER_DELAY          1.5f
#define CAMERA_CONTROLS_TRANSITION    0.2f

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface FilteredCameraViewController (PrivateAPI)

- (IBAction)captureStillImage:(id)sender;
- (void)showCameraConfig;
- (void)hideCameraConfig;
- (void)showCameraControls;
- (void)hideCameraControls;
- (void)openShutter;
- (void)closeShutter;
- (void)openShutterOnStart;
- (void)setCamera:(Camera*)_camera;
- (IBAction)toggleCameraConfiguration:(id)_sender;
- (IBAction)openApplicationConfiguration:(id)_sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)toggleAutoAdjustment:(id)sender;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation FilteredCameraViewController

@synthesize containerView, delegate, cameraSelectionView, captureImageGesture, cameraControlsView, cameraConfigView, 
            selectedCameraView, cameraAutoAdjustView, cameraParameterView, transitionGestureRecognizer,
            shutterView, cameraConfigIsShown;

#pragma mark -
#pragma mark FilteredCameraViewController PrivateAPI

- (IBAction)captureStillImage:(id)sender {
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

- (void)showCameraConfig {
    __block CGRect containerViewRect = CGRectMake(self.cameraConfigView.frame.origin.x, 0.0, 
                                                  self.cameraConfigView.frame.size.width, self.cameraConfigView.frame.size.height);
    [self.view addSubview:self.cameraConfigView];
    [UIView animateWithDuration:CAMERA_CONTROLS_TRANSITION
         delay:0.0
         options:UIViewAnimationOptionCurveEaseOut
         animations:^{
             self.cameraConfigView.frame = containerViewRect;
         }
         completion:^(BOOL _finished){
         }
     ];
}

- (void)hideCameraConfig {
    __block CGRect containerViewRect = CGRectMake(self.cameraConfigView.frame.origin.x, -self.cameraConfigView.frame.size.height, 
                                                  self.cameraConfigView.frame.size.width, self.cameraConfigView.frame.size.height);
    [UIView animateWithDuration:CAMERA_CONTROLS_TRANSITION
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            self.cameraConfigView.frame = containerViewRect;
        }
        completion:^(BOOL _finished){
            [self.cameraConfigView removeFromSuperview];
        }
     ];
}

- (void)showCameraControls {
    __block CGRect containerViewRect = CGRectMake(self.cameraControlsView.frame.origin.x, self.view.frame.size.height - self.cameraControlsView.frame.size.height, 
                                                  self.cameraControlsView.frame.size.width, self.cameraControlsView.frame.size.height);
    [UIView animateWithDuration:CAMERA_CONTROLS_TRANSITION
        delay:0.0
        options:UIViewAnimationOptionCurveEaseOut
        animations:^{
         self.cameraControlsView.frame = containerViewRect;
        }
        completion:^(BOOL _finished){
        }
     ];    
}

- (void)hideCameraControls {
    __block CGRect containerViewRect = CGRectMake(self.cameraControlsView.frame.origin.x, self.view.frame.size.height, 
                                                  self.cameraControlsView.frame.size.width, self.cameraControlsView.frame.size.height);
    [UIView animateWithDuration:CAMERA_CONTROLS_TRANSITION
         delay:0.0
         options:UIViewAnimationOptionCurveEaseOut
         animations:^{
             self.cameraControlsView.frame = containerViewRect;
         }
         completion:^(BOOL _finished){
         }
    ];
}

- (void)setCamera:(Camera*)_camera {
    [[CameraFactory instance] setCamera:_camera forView:(GPUImageView*)self.view];
    self.selectedCameraView.image = [UIImage imageNamed:_camera.imageFilename];
    if ([_camera.hasAutoAdjust boolValue]) {
        self.cameraAutoAdjustView.hidden = NO;
    } else {
        self.cameraAutoAdjustView.hidden = YES;
    }
    if ([_camera.hasParameter boolValue]) {
        self.cameraParameterView.maxValue = [_camera.maximumValue floatValue];
        self.cameraParameterView.minValue = [_camera.minimumValue floatValue];
        self.cameraParameterView.initialValue = [_camera.value floatValue];
        [self.cameraParameterView setParameterSliderValue];
        self.cameraParameterView.hidden = NO;
    } else {
        self.cameraParameterView.hidden = YES;
    }
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
            [self showCameraControls];
        }
    ];
}

- (IBAction)toggleCameraConfiguration:(id)_sender {
    if (self.cameraConfigIsShown) {
        [self hideCameraConfig];
        self.cameraConfigIsShown = NO;
    } else {
        [self showCameraConfig];
        self.cameraConfigIsShown = YES;
    }
}

- (IBAction)openApplicationConfiguration:(id)_sender {
    
}

- (IBAction)toggleAutoAdjustment:(id)sender {
    
}

- (IBAction)changeCamera:(id)sender {
    CGRect configViewRect = self.cameraConfigView.frame;
    CGRect controlsViewRect = self.cameraControlsView.frame;
    __block CGRect showConfigViewRect = CGRectMake(configViewRect.origin.x, -configViewRect.size.height, configViewRect.size.width, configViewRect.size.height);
    __block CGRect showControlViewRect = CGRectMake(controlsViewRect.origin.x, self.view.frame.size.height, controlsViewRect.size.width, controlsViewRect.size.height);
    __block CGRect hideConfigViewRect = CGRectMake(configViewRect.origin.x, 0.0, configViewRect.size.width, configViewRect.size.height);
    __block CGRect hideControlViewRect = CGRectMake(controlsViewRect.origin.x, self.view.frame.size.height - controlsViewRect.size.height, controlsViewRect.size.width, controlsViewRect.size.height);
    self.cameraSelectionView = [ParameterSelectionView initInView:self.view 
        withDelegate:self 
        showAnimation:^{
           self.cameraConfigView.frame = showConfigViewRect;
           self.cameraControlsView.frame = showControlViewRect;
        }
        hideAnimation:^{
            [UIView animateWithDuration:CAMERA_CONTROLS_TRANSITION
                 animations:^{
                     self.cameraConfigView.frame = hideConfigViewRect;
                     self.cameraControlsView.frame = hideControlViewRect;
                 } 
                 completion:^(BOOL _finished) {
                 }
            ];
        }
        andTitle:@"Cameras"
    ];
}

#pragma mark -
#pragma mark FilteredCameraViewController

+ (id)inView:(UIView*)_containerView {
    return [[FilteredCameraViewController alloc] initWithNibName:@"FilteredCameraViewController" bundle:nil inView:_containerView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inView:(UIView*)_containerView {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.containerView = _containerView;
        self.transitionGestureRecognizer = [TransitionGestureRecognizer initWithDelegate:self inView:self.view relativeToView:self.containerView];
        self.cameraConfigIsShown = NO;
        self.cameraParameterView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cameraConfigView.frame = CGRectMake(self.cameraConfigView.frame.origin.x, -self.cameraConfigView.frame.size.height, self.cameraConfigView.frame.size.width, self.cameraConfigView.frame.size.height);
    self.cameraControlsView.frame = CGRectMake(self.cameraControlsView.frame.origin.x, self.view.frame.size.height + self.cameraControlsView.frame.size.height, self.cameraControlsView.frame.size.width, self.cameraControlsView.frame.size.height);
    [self.cameraConfigView removeFromSuperview];
    [self openShutterOnStart];
    GPUImageView* gpuImageView = (GPUImageView*)self.view;
    gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
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
    [[ViewGeneral instance] transitionCameraToAlbums];    
}

- (void)didSwipeLeft:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [[ViewGeneral instance] transitionCameraToCalendar];    
}

- (void)didSwipeUp:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [[CameraFactory instance].stillCamera rotateCamera];
}

- (void)didSwipeDown:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

- (void)didReachMaxDragRight:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    [[ViewGeneral instance] transitionCameraToAlbums];    
}

- (void)didReachMaxDragLeft:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
    [[ViewGeneral instance] transitionCameraToCalendar];    
}

- (void)didReachMaxDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
    [[CameraFactory instance].stillCamera rotateCamera];
}

- (void)didReachMaxDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

#pragma mark -
#pragma mark ParameterSelectionViewDelegate

- (NSArray*)loadParameters {
    return [[CameraFactory instance] cameras];
}

- (void)configureParemeterCell:(ParameterSelectionCell*)_parameterCell withParameter:(id)_parameter {
    _parameterCell.parameterIcon.image = [UIImage imageNamed:[_parameter valueForKey:@"imageFilename"]];
    _parameterCell.parameterLabel.text = [_parameter valueForKey:@"name"];
}

- (void)selectedParameter:(id)_parameter {
    self.selectedCameraView.image = [UIImage imageNamed:[_parameter valueForKey:@"imageFilename"]];
    [self setCamera:_parameter];
    [self.cameraSelectionView removeView];
}

- (BOOL)canEdit {
    return NO;
}

- (void)done {
    [self.cameraSelectionView removeView];
}

#pragma mark -
#pragma mark ParameterSliderViewDelegate

-(void)parameterSliderValueChanged:(ParameterSliderView*)_parameterSlider {
    [[CameraFactory instance] setCameraParmeterValue:[NSNumber numberWithFloat:[_parameterSlider value]]];
}


@end
