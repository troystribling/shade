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

#define MAX_DRAG_FACTOR_FOR_SAVE_DELETE     0.6f
#define SAVE_DRAG_FACTOR                    0.1f
#define DELETE_DRAG_FACTOR                  0.25f
#define NONE_DRAG_FACTOR                    0.1f

@interface ImageInspectViewController ()

- (void)loadCaptures;
- (void)saveDisplayedImageEntryToCameraRoll;
- (void)drag:(CGPoint)__point;
- (void)releaseEntriesCircleView;
- (void)updateDownDragState;
- (void)initializeDownDragState;

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
    [[DataManager instance] performInBackground:^(NSManagedObjectContext *__context) {
        NSArray *captures = [Capture findAllInContext:__context];
        for (Capture *capture in captures) {
            UIImage *image = [[ViewGeneral instance] readImageWithId:[capture imageID]];
            NSManagedObjectID *captureId = capture.objectID;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addCapture:[Capture findWithID:captureId] andImage:image];
            });
        }
    }];
}

- (void)finishedSavingImageEntryToCameraRoll:(UIImage*)_image didFinishSavingWithError:(NSError*)__error contextInfo:(void*)__context {
    if (__error) {
        [[ViewGeneral instance] removeProgressView];
        [UIAlertView alertOnError:__error];
    } else {
        [[ViewGeneral instance] deleteImageWithId:[self.displayedImageEntry.capture imageID]];
        [self.displayedImageEntry.capture destroy];
        self.displayedImageEntry = nil;
        [[ViewGeneral instance] removeProgressView];
    }
}

- (void)saveDisplayedImageEntryToCameraRoll {
    [[ViewGeneral instance] showProgressViewWithMessage:@"Saving to Camera Roll"];
    UIImageWriteToSavedPhotosAlbum(self.displayedImageEntry.image, self, @selector(finishedSavingImageEntryToCameraRoll:didFinishSavingWithError:contextInfo:), nil);
}

- (void)drag:(CGPoint)__point {
    [[ViewGeneral instance] drag:__point view:self.entriesCircleView];
}

- (void)releaseEntriesCircleView {
    [self.entriesCircleView setMaximumDragFactor:self.originalMaxDragFactor];
    self.isDraggingDown = NO;
    switch (self.downDragState) {
        case ImageInspectDragStateNone: {
            [UIView animateWithDuration:[ViewGeneral verticalReleaseDuration:self.entriesCircleView.frame.origin.y]
                             animations:^{
                                 self.entriesCircleView.frame = self.view.frame;
                             }
                             completion:nil
             ];
            break;
        }
        case ImageInspectDragStateSave: {
            break;
        }
        case ImageInspectDragStateDelete: {
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
