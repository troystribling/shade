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

@interface ImageInspectViewController ()

- (void)loadCaptures;

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
    }
    return self;
}

- (void)addCapture:(Capture*)__capture andImage:(UIImage*)__image {
    [self.entriesStreamView addViewToRight:[ImageEntryView withCapture:__capture andImage:__image]];
}

- (BOOL)hasCaptures {
    return [self.entriesStreamView count] > 0;
}

#pragma mark -
#pragma mark ImageInspectViewController (PrivateAPI)

- (void)loadCaptures {
    NSArray *captures = [Capture findAll];
    for (Capture *capture in captures) {
        UIImage *image = [[ViewGeneral instance] readImageWithId:[NSString stringWithFormat:@"%@", capture.createdAt]];
        [self addCapture:capture andImage:image];
    }
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entriesStreamView = [StreamOfViews withFrame:self.view.frame delegate:self relativeToView:self.containerView];
    self.diagonalGestures = [DiagonalGestureRecognizer initWithDelegate:self];
    [self.entriesStreamView.transitionGestureRecognizer.gestureRecognizer requireGestureRecognizerToFail:self.diagonalGestures];
    [self.view addGestureRecognizer:self.diagonalGestures];
    [self.view addSubview:self.entriesStreamView];
    [self loadCaptures];
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
#pragma mark StreamOfViewsDelegate

- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] dragInspectImage:__drag];
}

- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
}

- (void)didReleaseUp:(CGPoint)_location {
    [[ViewGeneral instance] releaseInspectImage];
}

- (void)didReleaseDown:(CGPoint)__location {
}

- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionInspectImageToCamera];
}

- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)__velocity {
}

- (void)didReachMaxDragUp:(CGPoint)__drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] transitionInspectImageToCamera];
}

- (void)didReachMaxDragDown:(CGPoint)__drag from:(CGPoint)_location withVelocity:(CGPoint)__velocity {
}

- (void)didRemoveAllViews {
    [[ViewGeneral instance] transitionInspectImageToCamera];
}

#pragma mark -
#pragma mark DiagonalGestrureRecognizerDelegate

-(void)didCheck {
    ImageEntryView *entryView = (ImageEntryView*)[self.entriesStreamView displayedView];
    [self.entriesStreamView moveDisplayedViewDownAndRemove];
    [[ViewGeneral instance] saveImageEntryToCameraRoll:entryView];
    [entryView.capture destroy];
}

-(void)didDiagonalSwipe {
    ImageEntryView *entryView = (ImageEntryView*)[self.entriesStreamView displayedView];
    [self.entriesStreamView moveDisplayedViewDiagonallyAndRemove];
    [[ViewGeneral instance] deleteImageWithId:[NSString stringWithFormat:@"%@", entryView.capture.createdAt]];
    [entryView.capture destroy];
}

@end
