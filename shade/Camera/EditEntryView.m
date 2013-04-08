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
#import "CircleView.h"
#import "ViewGeneral.h"
#import "Capture+Extensions.h"

#define EDIT_MODE_TEXTBOX_YOFFSET   5.0f

@interface TextBoxView ()

- (void)addEditModeView;
- (void)didExitEditMode;
- (void)didChangeFilterParameter:(UIGestureRecognizer*)__gestureRecognizer;
- (void)addFilteredEntries:(ImageEntryView*)__entryView;

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
        self.filteredEntryCircleView = [CircleOfViews withFrame:self.frame delegate:self relativeToView:[ViewGeneral instance].view];
        UITapGestureRecognizer *selectEditMode = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didExitEditMode)];
        selectEditMode.numberOfTapsRequired = 1;
        selectEditMode.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:selectEditMode];
        UILongPressGestureRecognizer *changeFilterParameter = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didChangeFilterParameter:)];
        [self addGestureRecognizer:changeFilterParameter];
        [self addSubview:self.filteredEntryCircleView];
        [self addEditModeView];
        [self addFilteredEntries:__entryView];
        self.filterParametersAreChanging = NO;
    }
    return self;
}

#pragma mark -
#pragma mark EditEntryView PrivateView

- (void)addEditModeView {
    self.editModeTextBoxView = [TextBoxView withText:@"editing"];
    [self.editModeTextBoxView setTextXOffset:10.0f andYOffset:5.0f];
    CGRect editModeTextRect = self.editModeTextBoxView.frame;
    self.editModeTextBoxView.frame = CGRectMake(self.center.x - 0.5f * editModeTextRect.size.width,
                                                EDIT_MODE_TEXTBOX_YOFFSET,
                                                editModeTextRect.size.width,
                                                editModeTextRect.size.height);
    [self addSubview:self.editModeTextBoxView];
}

- (void)addFilteredEntries:(ImageEntryView*)__entryView {
    [self.filteredEntryCircleView addView:[__entryView clone]];
}

- (void)didExitEditMode {
    [self removeFromSuperview];
}

- (void)didChangeFilterParameter:(UIGestureRecognizer*)__gestureRecognizer {
    if (self.filterParametersAreChanging) {
//        CGPoint location = [__gestureRecognizer locationInView:self];
        if (__gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            self.filterParametersAreChanging = NO;
            NSLog(@"TOUCHES ENDED");            
        }
    } else {
        self.filterParametersAreChanging = YES;
        NSLog(@"TOUCHES BEGAN");
    }
}

#pragma mark -
#pragma mark CircleOfViews Delegate

- (void)didStartDraggingUp:(CGPoint)__location {
    
}

- (void)didDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    
}

- (void)didReleaseUp:(CGPoint)__location {
    
}

- (void)didSwipeUp:(CGPoint)__location withVelocity:(CGPoint)_velocity {
    
}

- (void)didReachMaxDragUp:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    
}

#pragma mark -

- (void)didStartDraggingDown:(CGPoint)__location {
    
}

- (void)didDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    
}

- (void)didReleaseDown:(CGPoint)__location {
    
}

- (void)didSwipeDown:(CGPoint)__location withVelocity:(CGPoint)_velocity {
    
}

- (void)didReachMaxDragDown:(CGPoint)__drag from:(CGPoint)__location withVelocity:(CGPoint)__velocity {
    
}

#pragma mark -

- (void)didStartDraggingRight:(CGPoint)__location {
}

- (void)didStartDraggingLeft:(CGPoint)__location {
}

- (void)didMoveLeft {
}

- (void)didReleaseLeft {
}

- (void)didMoveRight {
}

- (void)didReleaseRight {
}

- (void)didRemoveAllViews {
}

@end
