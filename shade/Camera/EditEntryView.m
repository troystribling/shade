//
//  EditEntryView.m
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "EditEntryView.h"
#import "ImageEntryView.h"
#import "TextBoxView.h"

@interface TextBoxView ()

- (void)addEditModeView;
- (void)didExitEditMode;

@end

@implementation EditEntryView

#pragma mark -
#pragma mark EditEntryView

+ (id)withEntry:(ImageEntryView*)__entryView {
    return [[self alloc] initWithEntry:__entryView];
}

- (id)initWithEntry:(ImageEntryView*)__entryView {
    self = [super initWithFrame:__entryView.frame];
    if (self) {
        [self addEditModeView];
        UITapGestureRecognizer *selectEditMode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didExitEditMode)];
        selectEditMode.numberOfTapsRequired = 1;
        selectEditMode.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:selectEditMode];
    }
    return self;
}

#pragma mark -
#pragma mark EditEntryView PrivateView

- (void)addEditModeView {
    self.editModeTextBoxView = [TextBoxView withText:@"editing"];
    CGRect editModeTextRect = self.editModeTextBoxView.frame;
    self.editModeTextBoxView.frame = CGRectMake(self.center.x - editModeTextRect.size.width, 10.0f, editModeTextRect.size.width, editModeTextRect.size.height);
    [self addSubview:self.editModeTextBoxView];
}

- (void)didExitEditMode {
    [self removeFromSuperview];
}

@end
