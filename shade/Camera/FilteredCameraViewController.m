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
#import "CameraFilterFactory.h"
#import "DataManager.h"
#import "AnimateView.h"

#define CAMERA_SHUTTER_TRANSITION     0.2f
#define CAMERA_SHUTTER_DELAY          1.5f

@interface FilteredCameraViewController ()

- (void)openShutter;
- (void)closeShutterAndOnCompletion:(void(^)(void))__completion;
- (void)animateShutterToAlpha:(float)__alpha onCompletion:(void(^)(void))__completion;
- (void)openShutterOnStart;
- (BOOL)hasCamera:(CameraId)__cameraId;
- (void)didCapture:(NSNotification*)__notification;

- (void)activateFilterWithCameraId:(CameraId)__cameraId forView:(GPUImageView*)__view;
- (void)deactivateFilterWithCameraId:(CameraId)__cameraId andOnCompletion:(void(^)(CameraId __cameraId))__completion;
- (void)startFilterCameraWithId:(CameraId)__cameraId;
- (void)stopFilterCameraWithId:(CameraId)__cameraId;

@end

@implementation FilteredCameraViewController

#pragma mark -
#pragma mark FilteredCameraViewController PrivateAPI

- (void)animateShutterToAlpha:(float)__alpha onCompletion:(void(^)(void))__completion {
    [AnimateView withDuration:CAMERA_SHUTTER_TRANSITION
                     animation:^{
                         self.shutterView.alpha = __alpha;
                     }
                     onCompletion:__completion
    ];
}

- (void)closeShutterAndOnCompletion:(void(^)(void))__completion {
    self.shutterView.alpha = 0.0;
    [self.view addSubview:self.shutterView];
    [self animateShutterToAlpha:1.0f onCompletion:__completion];
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

- (BOOL)hasCamera:(CameraId)__cameraId {
    return [self.cameraIds containsObject:[NSNumber numberWithInt:__cameraId]];
}

- (void)didCapture:(NSNotification*)__notification {
    [[DataManager instance] performInBackground:^(NSManagedObjectContext *__context) {
        NSManagedObjectID *captureId = [[__notification userInfo] objectForKey:@"captureId"];
        Capture *capture = [Capture findWithID:captureId inContext:__context];
        UIImage *image = [[ViewGeneral instance] readImageWithId:[capture imageID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ViewGeneral instance] addCapture:[Capture findWithID:captureId inContext:__context] andImage:image];
        });
    }];
}

- (void)activateFilterWithCameraId:(CameraId)__cameraId forView:(GPUImageView*)__view {
    [[CameraFilterFactory instance] activateCameraFilterWithCameraId:__cameraId forView:__view];
    [self startFilterCameraWithId:__cameraId];
}

- (void)deactivateFilterWithCameraId:(CameraId)__cameraId andOnCompletion:(void(^)(CameraId __cameraId))__completion {
    dispatch_async(self.cameraQueue, ^{
        [[CameraFilterFactory instance] stopFilterWithCameraId:__cameraId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[CameraFilterFactory instance] deactivateCameraFilterWithCameraId:__cameraId];
            if (__completion) {
                __completion(__cameraId);
            }
        });
    });
}

- (void)startFilterCameraWithId:(CameraId)__cameraId {
    dispatch_async(self.cameraQueue, ^{
        [[CameraFilterFactory instance] startFilterWithCameraId:__cameraId];
    });
}

- (void)stopFilterCameraWithId:(CameraId)__cameraId {
    dispatch_async(self.cameraQueue, ^{
        [[CameraFilterFactory instance] stopFilterWithCameraId:__cameraId];
    });
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
        self.cameraIds = [[CameraFilterFactory instance] cameraIds];
        self.cameraQueue = dispatch_queue_create("cameras.imaginaryproducts.com", NULL);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.camerasCircleView = [CircleOfViews withFrame:self.view.frame delegate:self relativeToView:self.containerView];
    [self.view addSubview:self.camerasCircleView];
    [self openShutterOnStart];
    for (NSNumber *camerId in self.cameraIds) {
        GPUImageView* gpuImageView = [[GPUImageView alloc] initWithFrame:self.view.frame];
        [self.camerasCircleView addView:gpuImageView];
    }
    self.displayedCameraId = [[CameraFilterFactory instance] defaultCameraId];
    [self activateDisplayedCameraFilter];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCapture:)
                                                 name:@"Capture"
                                               object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)captureStillImage:(id)__sender {
    self.captureImageGesture.enabled = NO;
    [self closeShutterAndOnCompletion:^{
        [[CameraFilterFactory instance] captureStillImageForFilterWithCameraId:self.displayedCameraId onCompletion:^(NSData* imageData, NSError* error) {
            if (error) {
                [ViewGeneral alertOnError:error];
            }
            else {
                [[DataManager instance] performInBackground:^(NSManagedObjectContext *context) {
                    Capture *capture = [Capture createInContext:context];
                    [capture save];
                    ViewGeneral *viewGeneral = [ViewGeneral instance];
                    [viewGeneral writeImage:imageData withId:[capture imageID] onCompletion:^(BOOL __status) {
                        if (__status) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"Capture"
                                                                                object:self
                                                                              userInfo:@{@"captureId" : capture.objectID}];
                        }
                    }];
                }];
            }
            self.captureImageGesture.enabled = YES;
            [self openShutter];
        }];
    }];
}

- (void)activateDisplayedCameraFilter {
    GPUImageView *imageView = (GPUImageView*)[self.camerasCircleView displayedView];
    [self activateFilterWithCameraId:self.displayedCameraId forView:imageView];
}

- (void)deactivateDisplayedCameraFilterAndOnCompletion:(void(^)(CameraId __cameraId))__completion {
    [self deactivateFilterWithCameraId:self.displayedCameraId andOnCompletion:__completion];
}

- (void)startDisplayedCameraFilter {
    [self startFilterCameraWithId:self.displayedCameraId];
}

- (void)stopDisplayedCameraFilter {
    [self stopFilterCameraWithId:self.displayedCameraId];
}

#pragma mark -
#pragma mark CircleOfViewsDelegate

#pragma mark -
#pragma mark Down

- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] dragCameraToInspectImage:__drag];
}

- (void)didReleaseDown:(CGPoint)__location {
    [[ViewGeneral instance] releaseCameraVertical];
}

- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

- (void)didReachMaxDragDown:(CGPoint)__drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionCameraToInspectImage];
}

#pragma mark -
#pragma mark Up

- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
}

- (void)didReleaseUp:(CGPoint)_location {
}

- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[CameraFilterFactory instance] rotateFilterCameraWithCameraId:self.displayedCameraId];
}

- (void)didReachMaxDragUp:(CGPoint)__drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
    [[CameraFilterFactory instance] rotateFilterCameraWithCameraId:self.displayedCameraId];
}

#pragma mark -
#pragma mark Circle of Views

- (void)didRemoveAllViews {
    [[ViewGeneral instance] transitionInspectImageToCamera];
}

#pragma mark -
#pragma mark Right

- (void)didStartDraggingRight:(CGPoint)__location {
    [self deactivateDisplayedCameraFilterAndOnCompletion:^(CameraId __cameraId) {
        CameraId leftCameraId = [[CameraFilterFactory instance] nextLeftCameraIdRelativeTo:__cameraId];
        GPUImageView *imageView = (GPUImageView*)[self.camerasCircleView nextLeftView];
        [self activateFilterWithCameraId:leftCameraId forView:imageView];
    }];
}

- (void)didMoveRight {
    self.displayedCameraId = [[CameraFilterFactory instance] nextLeftCameraIdRelativeTo:self.displayedCameraId];
}

- (void)didReleaseRight {
    CameraFilterFactory *factory = [CameraFilterFactory instance];
    CameraId leftCameraId = [factory nextLeftCameraIdRelativeTo:self.displayedCameraId];
    [self deactivateFilterWithCameraId:leftCameraId andOnCompletion:^(CameraId __cameraId) {
        [self activateDisplayedCameraFilter];
    }];
}

#pragma mark -
#pragma mark Left

- (void)didStartDraggingLeft:(CGPoint)__location {
    [self deactivateDisplayedCameraFilterAndOnCompletion:^(CameraId __cameraId) {
        CameraId rightCameraId = [[CameraFilterFactory instance] nextRightCameraIdRelativeTo:__cameraId];
        GPUImageView *imageView = (GPUImageView*)[self.camerasCircleView nextRightView];
        [self activateFilterWithCameraId:rightCameraId forView:imageView];
    }];
}

- (void)didMoveLeft {
    self.displayedCameraId = [[CameraFilterFactory instance] nextRightCameraIdRelativeTo:self.displayedCameraId];
}

- (void)didReleaseLeft {
    CameraFilterFactory *factory = [CameraFilterFactory instance];
    CameraId rightCameraId = [factory nextRightCameraIdRelativeTo:self.displayedCameraId];
    [self deactivateFilterWithCameraId:rightCameraId andOnCompletion:^(CameraId __cameraId) {
        [self activateDisplayedCameraFilter];
    }];
}

@end
