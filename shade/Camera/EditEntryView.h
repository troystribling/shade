//
//  EditEntryView.h
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleOfViews.h"

@class ImageEntryView;
@class TextBoxView;
@class CircleOfViews;

@interface EditEntryView : UIView <CircleOfViewsDelegate>

@property(nonatomic, strong) TextBoxView    *editModeTextBoxView;
@property(nonatomic, strong) CircleOfViews  *filteredEntryCircleView;
@property(nonatomic, assign) BOOL           filterParametersAreChanging;

+ (id)withEntry:(ImageEntryView*)__entryView;
- (id)initWithEntry:(ImageEntryView*)__entryView;

@end
