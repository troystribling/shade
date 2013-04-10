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
@class EditEntryView;

typedef enum  {
    ImageInspectDragStateNone,
    ImageInspectDragStateSave,
    ImageInspectDragStateDelete
}  ImageInspectDragState;

@interface ImageInspectViewController : UIViewController <CircleOfViewsDelegate>

@property(nonatomic, weak)   UIView                             *containerView;
@property(nonatomic, strong) CircleOfViews                      *entriesCircleView;
@property(nonatomic, strong) ImageEntryView                     *displayedImageEntry;
@property(nonatomic, strong) UIImageView                        *downDragSaveImageView;
@property(nonatomic, strong) UIImageView                        *downDragDeleteImageView;
@property(nonatomic, strong) EditEntryView                      *editEntryView;
@property(nonatomic, assign) float                              originalMaxDragFactor;
@property(nonatomic, assign) ImageInspectDragState              downDragState;
@property(nonatomic, assign) BOOL                               isDraggingDown;

+ (id)inView:(UIView*)__containerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle*)__nibBundleOrNil inView:(UIView*)__containerView;
- (void)finishedSavingDisplayedImageEntryToCameraRoll:(UIImage*)_image didFinishSavingWithError:(NSError*)__error contextInfo:(void*)__context;
- (void)addCapture:(Capture*)__capture andImage:(UIImage*)__image;
- (BOOL)hasCaptures;

@end
