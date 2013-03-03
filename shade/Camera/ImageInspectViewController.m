//
//  ImageInspectViewController.m
//  photio
//
//  Created by Troy Stribling on 2/19/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "ImageInspectViewController.h"
#import "ImageEntryView.h"
#import "UIImage+Resize.h"
#import "Capture.h"
#import "CaptureManager.h"
#import "ViewGeneral.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ImageInspectViewController (PrivateAPI)

- (void)saveCapture:(ImageEntryView*)_selectedView;
- (CLLocationManager*)locationManager;

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ImageInspectViewController

@synthesize entriesView, containerView, delegate;

#pragma mark -
#pragma mark ImageInspectViewController

+ (id)inView:(UIView*)_containerView withDelegate:(id<ImageInspectViewControllerDelegate>)_delegate {
    return [[ImageInspectViewController alloc] initWithNibName:@"ImageInspectViewController" bundle:nil inView:_containerView withDelegate:_delegate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil inView:(UIView*)_containerView withDelegate:(id<ImageInspectViewControllerDelegate>)_delegate {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.containerView = _containerView;
        self.delegate = _delegate;
    }
    return self;
}

- (void)addCapture:(Capture*)_capture {
    [self.entriesView addCaptureToRight:_capture];
}

- (BOOL)hasCaptures {
    return [self.entriesView entryCount] > 0;
}

#pragma mark -
#pragma mark ImageInspectViewController (PrivateAPI)

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entriesView = [ImageEntriesView withFrame:self.view.frame andDelegate:self];
    [self.view addSubview:self.entriesView];
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
#pragma mark ImageEntriesViewDelegate

- (void)dragEntries:(CGPoint)_drag {    
    if ([self.delegate respondsToSelector:@selector(dragInspectImage:)]) {
        [self.delegate dragInspectImage:_drag];
    }
}

- (void)releaseEntries {    
    if ([self.delegate respondsToSelector:@selector(releaseInspectImage)]) {
        [self.delegate releaseInspectImage];
    }
}

- (void)transitionUpFromEntries {    
    if ([self.delegate respondsToSelector:@selector(transitionFromInspectImage)]) {
        [self.delegate transitionFromInspectImage];
    }
}

- (void)transitionDownFromEntries {
    if ([self.delegate respondsToSelector:@selector(releaseInspectImage)]) {
        [self.delegate releaseInspectImage];
    }
}

- (void)didRemoveAllEntries:(ImageEntriesView*)_entries {
    if ([self.delegate respondsToSelector:@selector(transitionFromInspectImage)]) {
        [self.delegate transitionFromInspectImage];
    }
}

@end
