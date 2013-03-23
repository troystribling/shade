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
- (void)saveDisplayedImageEntryToCameraRoll;
- (void)drag:(CGPoint)__point;

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
    [[ViewGeneral instance] drag:__point view:self.view];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.entriesCircleView = [CircleOfViews withFrame:self.view.frame delegate:self relativeToView:self.containerView];
    [self.view addSubview:self.entriesCircleView];
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
#pragma mark CircleOfViewsDelegate

- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [[ViewGeneral instance] dragInspectImageToCamera:__drag];
}

- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    [self drag:__drag];
}

- (void)didReleaseUp:(CGPoint)_location {
    [[ViewGeneral instance] releaseInspectImageToCamera];
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

@end
