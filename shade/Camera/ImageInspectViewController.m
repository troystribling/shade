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
#import "EditEntryView.h"

#define MAX_DRAG_FACTOR_FOR_SAVE_DELETE     0.9f
#define REMOVE_SPEED                        800.0f
#define SAVE_DRAG_FACTOR                    0.1f
#define DELETE_DRAG_FACTOR                  0.4f
#define NONE_DRAG_FACTOR                    0.1f
#define DOWN_DRAG_IMAGE_SIZE                45.0f
#define DOWN_DRAG_IMAGE_OFFSET              5.0f

@interface ImageInspectViewController ()

- (void)loadCaptures;
- (void)saveDisplayedImageEntryToCameraRoll;
- (void)drag:(CGPoint)__point;
- (CGFloat)dragFactorForPoint:(CGPoint)__point;
- (void)releaseEntriesCircleView;

- (void)updateDownDragState;
- (void)initializeDownDragState;
- (void)setDownDragStateSave;
- (void)setDownDragStateDelete;
- (void)setDownDragImageRect;
- (CGRect)downDragImageViewExitRect;
- (CGRect)entriesCicrleViewExitRect;

- (void)destroyDisplayedImageEntry;
- (CGFloat)removeHorizontalDuration;
- (CGFloat)removeVerticalDuration;
- (void)moveEntriesCircleViewDownAndOnCompletion:(void(^)(UIView* __view))__completion;
- (void)setViewColors:(UIColor*)__color;

- (void)didEnterEditMode;

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
        CGRect downDragImageViewRect = CGRectMake(self.view.center.x - 0.5 * DOWN_DRAG_IMAGE_SIZE, 0.0, DOWN_DRAG_IMAGE_SIZE, DOWN_DRAG_IMAGE_SIZE);
        
        self.downDragSaveImageView = [[UIImageView alloc] initWithFrame:downDragImageViewRect];
        self.downDragSaveImageView.contentMode = UIViewContentModeScaleToFill;
        self.downDragSaveImageView.hidden = YES;
        self.downDragSaveImageView.image = [UIImage imageNamed:@"save"];
        [self.view addSubview:self.downDragSaveImageView];
        
        self.downDragDeleteImageView = [[UIImageView alloc] initWithFrame:downDragImageViewRect];
        self.downDragDeleteImageView.contentMode = UIViewContentModeScaleToFill;
        self.downDragDeleteImageView.hidden = YES;
        self.downDragDeleteImageView.image = [UIImage imageNamed:@"delete"];
        [self.view addSubview:self.downDragDeleteImageView];
        
        self.entriesCircleView = [CircleOfViews withFrame:self.view.frame delegate:self relativeToView:self.containerView];
        [self.view addSubview:self.entriesCircleView];
        [self loadCaptures];
        self.originalMaxDragFactor = [self.entriesCircleView maximumDragFactor];
        [self initializeDownDragState];
        self.isDraggingDown = NO;
        
        UITapGestureRecognizer *selectEditMode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didEnterEditMode)];
        selectEditMode.numberOfTapsRequired = 1;
        selectEditMode.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:selectEditMode];
        [self.entriesCircleView.transitionGestureRecognizer.gestureRecognizer requireGestureRecognizerToFail:selectEditMode];
    
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

- (void)finishedSavingDisplayedImageEntryToCameraRoll:(UIImage*)_image didFinishSavingWithError:(NSError*)__error contextInfo:(void*)__context {
    if (!__error) {
        [self destroyDisplayedImageEntry];
        [[ViewGeneral instance] removeProgressView];
    } else {
        [[ViewGeneral instance] removeProgressView];
        [UIAlertView alertOnError:__error];
    }
}

- (void)saveDisplayedImageEntryToCameraRoll {
    [[ViewGeneral instance] showProgressViewWithMessage:@"Saving to Camera Roll"];
    UIImageWriteToSavedPhotosAlbum(self.displayedImageEntry.image, self, @selector(finishedSavingDisplayedImageEntryToCameraRoll:didFinishSavingWithError:contextInfo:), nil);
}

- (void)drag:(CGPoint)__point {
    [AnimateView drag:__point view:self.entriesCircleView];
    float dragFactor = [self dragFactorForPoint:CGPointMake(0.0,__point.y+self.entriesCircleView.frame.origin.y)];
    if (dragFactor > SAVE_DRAG_FACTOR) {
        CGPoint dragPoint = CGPointMake(__point.x, __point.y);
        [AnimateView drag:dragPoint view:self.downDragSaveImageView];
        [AnimateView drag:dragPoint view:self.downDragDeleteImageView];
    }
}

- (CGFloat)dragFactorForPoint:(CGPoint)__point {
    float screenHeight = self.view.frame.size.height;
    return __point.y / screenHeight;
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
            [self moveEntriesCircleViewDownAndOnCompletion:^(UIView *__view) {
                self.displayedImageEntry = (ImageEntryView*)__view;
                [self saveDisplayedImageEntryToCameraRoll];
            }];
            break;
        }
        case ImageInspectDragStateDelete: {
            [self moveEntriesCircleViewDownAndOnCompletion:^(UIView *__view) {
                self.displayedImageEntry = (ImageEntryView*)__view;
                [self destroyDisplayedImageEntry];
            }];
            break;
        }
    }
}

- (void)updateDownDragState {
    float dragFactor = [self dragFactorForPoint:self.entriesCircleView.frame.origin];
    switch (self.downDragState) {
        case ImageInspectDragStateNone: {
            if (dragFactor > SAVE_DRAG_FACTOR) {
                [self setDownDragStateSave];
            }
            break;
        }
        case ImageInspectDragStateSave: {
            if (dragFactor > DELETE_DRAG_FACTOR) {
                [self setDownDragStateDelete];
            } else if (dragFactor < NONE_DRAG_FACTOR) {
                [self initializeDownDragState];
            }
            break;
        }
        case ImageInspectDragStateDelete: {
            if (dragFactor < DELETE_DRAG_FACTOR) {
                [self setDownDragStateSave];
            }
            break;
        }
    }
}

- (void)initializeDownDragState {
    self.downDragState = ImageInspectDragStateNone;
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.entriesCircleView.backgroundColor = [UIColor blackColor];
    self.containerView.backgroundColor = [UIColor blackColor];
    self.downDragSaveImageView.hidden = YES;
    self.downDragDeleteImageView.hidden = YES;
}

- (void)setDownDragStateSave {
    self.downDragState = ImageInspectDragStateSave;
    self.downDragDeleteImageView.hidden = YES;
    self.downDragSaveImageView.hidden = NO;
    self.view.backgroundColor = [UIColor greenColor];
    [self setDownDragImageRect];
}

- (void)setDownDragStateDelete {
    self.downDragState = ImageInspectDragStateDelete;
    [self setViewColors:[UIColor redColor]];
    self.downDragDeleteImageView.hidden = NO;
    self.downDragSaveImageView.hidden = YES;
    [self setDownDragImageRect];
}

- (void)setDownDragImageRect {
    CGRect downDragImageViewRect = CGRectMake(self.view.center.x - 0.5 * DOWN_DRAG_IMAGE_SIZE,
                                              self.entriesCircleView.frame.origin.y - DOWN_DRAG_IMAGE_SIZE - DOWN_DRAG_IMAGE_OFFSET,
                                              DOWN_DRAG_IMAGE_SIZE, DOWN_DRAG_IMAGE_SIZE);
    self.downDragSaveImageView.frame = downDragImageViewRect;
    self.downDragDeleteImageView.frame = downDragImageViewRect;
}

- (CGRect)downDragImageViewExitRect {
    return CGRectMake(self.view.center.x - 0.5 * DOWN_DRAG_IMAGE_SIZE,
                      self.entriesCircleView.frame.size.height,
                      DOWN_DRAG_IMAGE_SIZE, DOWN_DRAG_IMAGE_SIZE);
}

- (CGRect)entriesCicrleViewExitRect {
    CGRect underWindowRect = [AnimateView underWindowRect];
    return CGRectMake(underWindowRect.origin.x,
                      underWindowRect.origin.y + DOWN_DRAG_IMAGE_SIZE,
                      underWindowRect.size.width, underWindowRect.size.height);
}

- (void)destroyDisplayedImageEntry {
    Capture *displayedCapture = [Capture findWithID:[self.displayedImageEntry.capture objectID]];
    NSString *imageId = [displayedCapture imageID];
    [[ViewGeneral instance] deleteImageWithId:imageId];
    [displayedCapture destroy];
}

- (CGFloat)removeHorizontalDuration {
    return [AnimateView horizontalTransitionDuration:0.0f];
}

- (CGFloat)removeVerticalDuration {
    return [AnimateView verticalTransitionDuration:self.entriesCircleView.frame.origin.y withSpeed:REMOVE_SPEED];
}

- (void)moveEntriesCircleViewDownAndOnCompletion:(void(^)(UIView* __view))__completion {
    [AnimateView withDuration:[self removeVerticalDuration]
                    animation:^{
                        self.entriesCircleView.frame = [self entriesCicrleViewExitRect];
                        self.downDragSaveImageView.frame = [self downDragImageViewExitRect];
                        self.downDragDeleteImageView.frame = [self downDragImageViewExitRect];
                    }
                 onCompletion:^{
                     UIView* removedView = [self.entriesCircleView removeDisplayedView];
                     __completion(removedView);
                     [self.entriesCircleView replaceRemovedView];
                     self.downDragSaveImageView.hidden = YES;
                     self.downDragDeleteImageView.hidden = YES;
                     if ([self.entriesCircleView count] > 0) {
                         [self.entriesCircleView hideLeftViews:YES];
                         self.entriesCircleView.frame = [AnimateView rightOfWindowRect];
                         [AnimateView withDuration:[self removeHorizontalDuration]
                                      animation:^{
                                          self.entriesCircleView.frame = [AnimateView inWindowRect];
                                      }
                                      onCompletion:^{
                                          [self.entriesCircleView hideLeftViews:NO];
                                          [self initializeDownDragState];
                                      }
                          ];
                     } else {
                         self.entriesCircleView.frame = [AnimateView inWindowRect];
                     }
                 }
     ];
}

- (void)setViewColors:(UIColor*)__color {
    self.view.backgroundColor = __color;
    self.entriesCircleView.backgroundColor = __color;
    self.containerView.backgroundColor = __color;
}

- (void)didEnterEditMode {
    if ([self hasCaptures]) {
        self.editEntryView = [EditEntryView withEntry:(ImageEntryView*)[self.entriesCircleView displayedView]];
        [self.view addSubview:self.editEntryView];
    }
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
