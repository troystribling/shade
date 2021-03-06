//
//  EditEntryView.m
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "EditEntryView.h"
#import "ImageEntryView.h"
#import "TextBoxView.h"
#import "CircleView.h"
#import "ViewGeneral.h"
#import "Capture+Extensions.h"
#import "Camera+Extensions.h"
#import "CameraFilterFactory.h"

#define EDIT_MODE_TEXTBOX_OFFSET        2.0f
#define CHANGE_FILTER_PARAMTER_RADIUS   50.0f

@interface EditEntryView ()

- (void)didExitEditMode;
- (void)didChangeFilterParameter:(UIGestureRecognizer*)__gestureRecognizer;

- (void)addEditModeView:(NSString*)__editModeString;
- (void)addEditModeViewForInViewCamera;
- (void)activateFilterWithCameraId:(CameraId)__cameraId forView:(GPUImageView*)__view;
- (void)deactivateFilterWithCameraId:(CameraId)__cameraId;
- (void)activateDisplayedCamera;
- (void)deactivateDisplayedCamera;

@end

@implementation EditEntryView

#pragma mark -
#pragma mark EditEntryView

+ (id)withEntry:(ImageEntryView*)__entryView {
    return [[self alloc] initWithEntry:__entryView];
}

- (id)initWithEntry:(ImageEntryView*)__entryView {
    self = [super initWithFrame:__entryView.frame];
    if (self) {
        self.entryView = __entryView;
        CameraFilterFactory *cameraFilterFactory = [CameraFilterFactory instance];
        self.cameraIds = [cameraFilterFactory cameraIds];
        self.displayedCameraId = [cameraFilterFactory defaultCameraId];
        self.filteredEntryCircleView = [CircleOfViews withFrame:self.frame delegate:self relativeToView:[ViewGeneral instance].view];
        for (NSNumber *camerId in self.cameraIds) {
            GPUImageView* gpuImageView = [[GPUImageView alloc] initWithFrame:self.frame];
            gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
            [self.filteredEntryCircleView addView:gpuImageView];
        }
        [self activateDisplayedCamera];
        UITapGestureRecognizer *selectEditMode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didExitEditMode)];
        selectEditMode.numberOfTapsRequired = 1;
        selectEditMode.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:selectEditMode];
        UILongPressGestureRecognizer *changeFilterParameter = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didChangeFilterParameter:)];
        [self addGestureRecognizer:changeFilterParameter];
        [self addSubview:self.filteredEntryCircleView];
        [self addEditModeViewForInViewCamera];
        self.changeFilterParameterCircleView = [CircleView withRadius:CHANGE_FILTER_PARAMTER_RADIUS centeredAt:self.center];
        self.filterParametersAreChanging = NO;
    }
    return self;
}

#pragma mark -
#pragma mark EditEntryView PrivateView

- (void)didExitEditMode {
    [self deactivateDisplayedCamera];
    [self removeFromSuperview];
}


- (void)didChangeFilterParameter:(UIGestureRecognizer*)__gestureRecognizer {
    CGPoint location = [__gestureRecognizer locationInView:self];
    if (self.filterParametersAreChanging) {
        self.changeFilterParameterCircleView.center = location;
        if (__gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            self.filterParametersAreChanging = NO;
            [self.changeFilterParameterCircleView removeFromSuperview];
            [self addEditModeViewForInViewCamera];
        }
    } else {
        self.filterParametersAreChanging = YES;
        self.changeFilterParameterCircleView.center = location;
        [self addEditModeView:@"Adjusting Filter"];
        [self addSubview:self.changeFilterParameterCircleView];
    }
}

#pragma mark -

- (void)addEditModeView:(NSString*)__editModeString {
    if (self.editModeTextBoxView) {
        [self.editModeTextBoxView removeFromSuperview];
    }
    self.editModeTextBoxView = [TextBoxView withText:__editModeString];
    [self.editModeTextBoxView setTextXOffset:20.0f andYOffset:5.0f];
    CGRect editModeTextRect = self.editModeTextBoxView.frame;
    self.editModeTextBoxView.frame = CGRectMake(self.center.x - 0.5f * editModeTextRect.size.width,
                                                EDIT_MODE_TEXTBOX_OFFSET,
                                                editModeTextRect.size.width,
                                                editModeTextRect.size.height);
    [self addSubview:self.editModeTextBoxView];
}

- (void)addEditModeViewForInViewCamera {
    Camera *camera = [Camera findFirstWithCameraId:self.displayedCameraId];
    [self addEditModeView:[NSString stringWithFormat:@"%@ Filter", camera.name]];
}

- (void)activateFilterWithCameraId:(CameraId)__cameraId  forView:(GPUImageView*)__view {
    [[CameraFilterFactory instance] activatePictureFilterWithCameraId:__cameraId forView:__view withImage:[self.entryView imageClone]];
}

- (void)deactivateFilterWithCameraId:(CameraId)__cameraId {
    [[CameraFilterFactory instance] deactivatePictureFilterWithCameraId:__cameraId];
}

- (void)activateDisplayedCamera {
    GPUImageView *imageView = (GPUImageView*)[self.filteredEntryCircleView displayedView];
    [self activateFilterWithCameraId:self.displayedCameraId forView:imageView];
}

- (void)deactivateDisplayedCamera {
    [self deactivateFilterWithCameraId:self.displayedCameraId];
}

#pragma mark -
#pragma mark CircleOfViews Delegate

- (void)didStartDraggingUp:(CGPoint)__location {
    
}

- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    
}

- (void)didReleaseUp:(CGPoint)__location {
    
}

- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)_velocity {
    
}

- (void)didReachMaxDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    
}

#pragma mark -

- (void)didStartDraggingDown:(CGPoint)__location {
    
}

- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    
}

- (void)didReleaseDown:(CGPoint)__location {
    
}

- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)_velocity {
    
}

- (void)didReachMaxDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    
}

#pragma mark -

- (void)didStartDraggingRight:(CGPoint)__location {
    [self deactivateDisplayedCamera];
    CameraId leftCameraId = [[CameraFilterFactory instance] nextLeftCameraIdRelativeTo:self.displayedCameraId];
    GPUImageView *imageView = (GPUImageView*)[self.filteredEntryCircleView nextLeftView];
    [self activateFilterWithCameraId:leftCameraId forView:imageView];
}

- (void)didMoveRight {
    self.displayedCameraId = [[CameraFilterFactory instance] nextLeftCameraIdRelativeTo:self.displayedCameraId];
}

- (void)didReleaseRight {
    CameraFilterFactory *factory = [CameraFilterFactory instance];
    CameraId leftCameraId = [factory nextLeftCameraIdRelativeTo:self.displayedCameraId];
    [self deactivateFilterWithCameraId:leftCameraId];
}

#pragma mark -

- (void)didStartDraggingLeft:(CGPoint)__location {
    [self deactivateDisplayedCamera];
    CameraId rightCameraId = [[CameraFilterFactory instance] nextRightCameraIdRelativeTo:self.displayedCameraId];
    GPUImageView *imageView = (GPUImageView*)[self.filteredEntryCircleView nextRightView];
    [self activateFilterWithCameraId:rightCameraId forView:imageView];
}

- (void)didMoveLeft {
    self.displayedCameraId = [[CameraFilterFactory instance] nextRightCameraIdRelativeTo:self.displayedCameraId];
}

- (void)didReleaseLeft {
    CameraFilterFactory *factory = [CameraFilterFactory instance];
    CameraId rightCameraId = [factory nextRightCameraIdRelativeTo:self.displayedCameraId];
    [self deactivateFilterWithCameraId:rightCameraId];
}

#pragma mark -
- (void)didRemoveAllViews {
}

@end
