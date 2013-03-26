//
//  ImageInspectViewController.m
//  photio
//
//  Created by Troy Stribling on 2/19/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "ImageInspectViewController.h"
#import "ViewGeneral.h"
#import "ImageEntryView.h"
#import "UIImage+Resize.h"
#import "Capture+Extensions.h"
#import "UIAlertView+Extensions.h"
#import "AnimateView.h"

#define MAX_DRAG_FACTOR_FOR_SAVE_DELETE     0.6f
#define SAVE_DRAG_FACTOR                    0.1f
#define DELETE_DRAG_FACTOR                  0.25f
#define NONE_DRAG_FACTOR                    0.1f

@interface ImageInspectViewController ()

- (void)loadCaptures;
- (void)saveImageEntryToCameraRoll:(ImageEntryView*)__imageEntryView;
- (void)drag:(CGPoint)__point;
- (void)releaseEntriesCircleView;
- (void)updateDownDragState;
- (void)initializeDownDragState;
- (void)destroyImageEntry:(ImageEntryView*)__imageEntryView;

@end

@implementation ImageInspectViewController

#pragma mark -
#pragma mark ImageInspectViewController

+ (id)inView:(UIView*)__containerView {
    return [[ImageInspectViewController alloc] initWithNibName:@"ImageInspectViewController" bundle:nil inView:__containerView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
               inView:(UIView*)__containerView {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.containerView = __containerView;
        [super viewDidLoad];
        self.entriesCircleView = [CircleOfViews withFrame:self.view.frame delegate:self relativeToView:self.containerView];
        [self.view addSubview:self.entriesCircleView];
        [self loadCaptures];
        self.originalMaxDragFactor = [self.entriesCircleView maximumDragFactor];
        [self initializeDownDragState];
        self.isDraggingDown = NO;
    }
    return self;
}

- (void)addCapture:(Capture*)__capture andImageData:(NSData*)__imageData {
    [self.entriesCircleView addView:[ImageEntryView withFrame:self.view.frame capture:__capture andImageData:__imageData]];
}

- (void)addCapture:(Capture*)__capture andImage:(UIImage*)__image {
    [self.entriesCircleView addView:[ImageEntryView withCapture:__capture andImage:__image]];
}

- (BOOL)hasCaptures {
    return [self.entriesCircleView count] > 0;
}

#pragma mark -
#pragma mark ImageInspectViewController (PrivateAPI)

- (void)loadCaptures {
    NSArray *captures = [Capture findAll];
    for (Capture *capture in captures) {
        NSString *imageId = [capture imageID];
        UIImage *image = [[ViewGeneral instance] readImageWithId:imageId];
        [self addCapture:capture andImage:image];
    }
}

- (void)finishedSavingImageEntryToCameraRoll:(UIImage*)_image didFinishSavingWithError:(NSError*)__error contextInfo:(void*)__context {
    [[ViewGeneral instance] removeProgressView];
    if (__error) {
        [UIAlertView alertOnError:__error];
    }
}

- (void)saveImageEntryToCameraRoll:(ImageEntryView*)__imageEntryView {
    [[ViewGeneral instance] showProgressViewWithMessage:@"Saving to Camera Roll"];
    UIImageWriteToSavedPhotosAlbum(__imageEntryView.image, self, @selector(finishedSavingImageEntryToCameraRoll:didFinishSavingWithError:contextInfo:), nil);
}

- (void)drag:(CGPoint)__point {
    [AnimateView drag:__point view:self.entriesCircleView];
}

- (void)releaseEntriesCircleView {
    [self.entriesCircleView setMaximumDragFactor:self.originalMaxDragFactor];
    self.isDraggingDown = NO;
    switch (self.downDragState) {
        case ImageInspectDragStateNone: {
            [AnimateView withDuration:[AnimateView verticalReleaseDuration:self.entriesCircleView.frame.origin.y]
                             andAnimation:^{
                                 self.entriesCircleView.frame = self.view.frame;
                             }
             ];
            break;
        }
        case ImageInspectDragStateSave: {
            [self.entriesCircleView moveDisplayedViewDownRemoveAndOnCompletion:^(UIView *__view) {
                ImageEntryView *entryView = (ImageEntryView*)__view;
                [self saveImageEntryToCameraRoll:entryView];
                [self destroyImageEntry:entryView];
            }];
            break;
        }
        case ImageInspectDragStateDelete: {
            [self.entriesCircleView moveDisplayedViewDownRemoveAndOnCompletion:^(UIView *__view) {
                ImageEntryView *entryView = (ImageEntryView*)__view;
                [self destroyImageEntry:entryView];
            }];
            break;
        }
    }
}

- (void)updateDownDragState {
    float screenHeight = self.view.frame.size.height;
    float dragFactor = self.entriesCircleView.frame.origin.y / screenHeight;
    switch (self.downDragState) {
        case ImageInspectDragStateNone: {
            if (dragFactor > SAVE_DRAG_FACTOR) {
                self.downDragState = ImageInspectDragStateSave;
                self.view.backgroundColor = [UIColor greenColor];
            }
            break;
        }
        case ImageInspectDragStateSave: {
            if (dragFactor > DELETE_DRAG_FACTOR) {
                self.downDragState = ImageInspectDragStateDelete;
                self.view.backgroundColor = [UIColor redColor];
            } else if (dragFactor < NONE_DRAG_FACTOR) {
                [self initializeDownDragState];
            }
            break;
        }
        case ImageInspectDragStateDelete: {
            if (dragFactor < DELETE_DRAG_FACTOR) {
                self.downDragState = ImageInspectDragStateSave;
                self.view.backgroundColor = [UIColor greenColor];
            } else if (dragFactor < NONE_DRAG_FACTOR) {
                [self initializeDownDragState];
            }
            break;
        }
    }
}

- (void)initializeDownDragState {
    self.downDragState = ImageInspectDragStateNone;
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)destroyImageEntry:(ImageEntryView*)__imageEntryView {
    NSString *imageId = [__imageEntryView.capture imageID];
    [[ViewGeneral instance] deleteImageWithId:imageId];
    [__imageEntryView.capture destroy];
    [__imageEntryView.capture save];
    [self initializeDownDragState];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark CircleOfViewsDelegate

#pragma mark -
#pragma mark Down Events

- (void)didStartDraggingDown:(CGPoint)__location {
    [self.entriesCircleView setMaximumDragFactor:MAX_DRAG_FACTOR_FOR_SAVE_DELETE];
}

- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [self drag:__drag];
    [self updateDownDragState];
    self.isDraggingDown = YES;
}

- (void)didReleaseDown:(CGPoint)__location {
    [self releaseEntriesCircleView];
}

- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [self releaseEntriesCircleView];
}

- (void)didReachMaxDragDown:(CGPoint)__drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
    [self releaseEntriesCircleView];
}

#pragma mark -
#pragma mark Up Events

- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    if (self.isDraggingDown) {
        [self drag:__drag];
        [self updateDownDragState];
    } else {
        [[ViewGeneral instance] dragInspectImageToCamera:__drag];
    }
}

- (void)didReleaseUp:(CGPoint)_location {
    [[ViewGeneral instance] releaseInspectImageToCamera];
}

- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionInspectImageToCamera];
}

- (void)didReachMaxDragUp:(CGPoint)__drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionInspectImageToCamera];
}

#pragma mark -
#pragma mark Other Events

- (void)didRemoveAllViews {
    [[ViewGeneral instance] transitionInspectImageToCamera];
}

@end
