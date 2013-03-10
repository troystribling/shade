//
//  ImageInspectViewController.h
//  photio
//
//  Created by Troy Stribling on 2/19/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiagonalGestureRecognizer.h"
#import "StreamOfViews.h"

@class Capture;
@class ImageEntryView;
 
@interface ImageInspectViewController : UIViewController <UIImagePickerControllerDelegate, StreamOfViewsDelegate, DiagonalGestureRecognizerDelegate>

@property(nonatomic, weak)   UIView                             *containerView;
@property(nonatomic, strong) DiagonalGestureRecognizer          *diagonalGestures;
@property(nonatomic, strong) StreamOfViews                      *entriesStreamView;
@property(nonatomic, strong) ImageEntryView                     *displayedImageEntry;

+ (id)inView:(UIView*)__containerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle*)__nibBundleOrNil inView:(UIView*)__containerView;
- (void)finishedSavingImageEntryToCameraRoll:(UIImage*)_image didFinishSavingWithError:(NSError*)__error contextInfo:(void*)__context;
- (void)addCapture:(Capture*)__capture andImage:(UIImage*)__image;
- (BOOL)hasCaptures;

@end
