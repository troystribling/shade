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
@class CircleView;

@interface EditEntryView : UIView <CircleOfViewsDelegate>

@property(nonatomic, strong) ImageEntryView *entryView;
@property(nonatomic, strong) TextBoxView    *editModeTextBoxView;
@property(nonatomic, strong) CircleOfViews  *filteredEntryCircleView;
@property(nonatomic, strong) CircleView     *changeFilterParameterCircleView;
@property(nonatomic, strong) NSArray        *cameras;
@property(nonatomic, assign) BOOL           filterParametersAreChanging;

+ (id)withEntry:(ImageEntryView*)__entryView;
- (id)initWithEntry:(ImageEntryView*)__entryView;

@end
