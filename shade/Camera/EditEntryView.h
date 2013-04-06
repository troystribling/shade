//
//  EditEntryView.h
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageEntryView;
@class TextBoxView;

@interface EditEntryView : UIView

@property(nonatomic, strong) TextBoxView    *editModeTextBoxView;

+ (id)withEntry:(ImageEntryView*)__entryView;
- (id)initWithEntry:(ImageEntryView*)__entryView;

@end
