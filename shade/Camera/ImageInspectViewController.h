//
//  ImageInspectViewController.h
//  photio
//
//  Created by Troy Stribling on 2/19/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleOfViews.h"

@class Capture;
@class ImageEntryView;

@interface ImageInspectViewController : UIViewController <CircleOfViewsDelegate>

@property(nonatomic, weak)   UIView                             *containerView;
@property(nonatomic, strong) CircleOfViews                      *entriesCircleView;
@property(nonatomic, strong) ImageEntryView                     *displayedImageEntry;

+ (id)inView:(UIView*)__containerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle*)__nibBundleOrNil inView:(UIView*)__containerView;
- (void)finishedSavingImageEntryToCameraRoll:(UIImage*)_image didFinishSavingWithError:(NSError*)__error contextInfo:(void*)__context;
- (void)addCapture:(Capture*)__capture andImage:(UIImage*)__image;
- (void)addCapture:(Capture*)__capture andImageData:(NSData*)__imageData;
- (BOOL)hasCaptures;

@end
