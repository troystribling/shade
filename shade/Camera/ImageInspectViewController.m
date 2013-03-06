//
//  ImageInspectViewController.m
//  photio
//
//  Created by Troy Stribling on 2/19/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "ImageInspectViewController.h"
#import "UIImage+Resize.h"
#import "Capture+Extensions.h"
#import "ViewGeneral.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ImageInspectViewController ()

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ImageInspectViewController

#pragma mark -
#pragma mark ImageInspectViewController

+ (id)inView:(UIView*)__containerView withDelegate:(id<ImageInspectViewControllerDelegate>)__delegate {
    return [[ImageInspectViewController alloc] initWithNibName:@"ImageInspectViewController" bundle:nil inView:__containerView withDelegate:__delegate];
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
               inView:(UIView*)__containerView
         withDelegate:(id<ImageInspectViewControllerDelegate>)__delegate {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.containerView = __containerView;
        self.delegate = __delegate;
    }
    return self;
}

- (void)addCapture:(Capture*)__capture {
    [self.entriesView addCaptureToRight:__capture];
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

- (void)dragEntries:(CGPoint)__drag {
    if ([self.delegate respondsToSelector:@selector(dragInspectImage:)]) {
        [self.delegate dragInspectImage:__drag];
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

- (void)didRemoveAllEntries:(ImageEntriesView*)__entries {
    if ([self.delegate respondsToSelector:@selector(transitionFromInspectImage)]) {
        [self.delegate transitionFromInspectImage];
    }
}

@end
