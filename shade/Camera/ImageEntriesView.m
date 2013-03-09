//
//  ImageEntriesView.m
//  photio
//
//  Created by Troy Stribling on 2/19/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "ImageEntriesView.h"
#import "ImageEntryView.h"
#import "StreamOfViews.h"
#import "Capture+Extensions.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define LOADED_ENTRIES_BUFFER   1

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ImageEntriesView ()

- (void)moveLeft;
- (void)moveRight;
- (BOOL)canAddRightView;
- (BOOL)canRemoveRightView;
- (BOOL)canAddLeftView;
- (BOOL)canRemoveLeftView;
- (void)removeEntry:(UIImageView*)_entry;
- (void)loadEntries;
- (void)singleTapGesture;

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ImageEntriesView


#pragma mark -
#pragma mark ImageEntriesView

+ (id)withFrame:(CGRect)_frame andDelegate:(id<ImageEntriesViewDelegate>)_delegate {
    return [[ImageEntriesView alloc] initWithFrame:_frame andDelegate:_delegate];
}

- (id)initWithFrame:(CGRect)_frame andDelegate:(id<ImageEntriesViewDelegate>)__delegate {
    if ((self = [super initWithFrame:_frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.delegate = __delegate;
        self.entries = [NSMutableArray arrayWithCapacity:10];
        self.entriesStreamView = [StreamOfViews withFrame:self.frame delegate:self relativeToView:self.containerView];
        self.diagonalGestures = [DiagonalGestureRecognizer initWithDelegate:self];
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [self.entriesStreamView.transitionGestureRecognizer.gestureRecognizer requireGestureRecognizerToFail:self.diagonalGestures];
        [self.diagonalGestures requireGestureRecognizerToFail:singleTap];
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:self.diagonalGestures];
        [self addSubview:self.entriesStreamView];
        [self loadEntries];
        self.inViewIndex = 0;
        self.leftMostIndex = 0;
        self.rightMostIndex = 0;
    }
    return self;
}

- (NSInteger)entryCount {
    return [self.entries count];
}

- (void)addEntryToRight:(ImageEntryView*)__entry {
    NSInteger rightWidth = self.rightMostIndex - self.inViewIndex;
    if (rightWidth < LOADED_ENTRIES_BUFFER) {
        if ([self entryCount] > 0) {
            self.rightMostIndex++;
        }
        [self.entriesStreamView addViewToRight:__entry];
    }
    [self.entries addObject:__entry];
}

- (void)addEntryToLeft:(ImageEntryView*)__entry {
    NSInteger leftWidth = self.inViewIndex - self.leftMostIndex;
    if (leftWidth < LOADED_ENTRIES_BUFFER) {
        if (self.inViewIndex > LOADED_ENTRIES_BUFFER) {
            self.leftMostIndex++;
        }
        if ([self.entries count] > 0) {
            self.inViewIndex++;
            self.rightMostIndex++;
        }
        [self.entriesStreamView addViewToLeft:__entry];
    }
    [self.entries insertObject:__entry atIndex:0];
}

- (void)singleTapGesture {
}

#pragma mark -
#pragma mark ImageEntriesView (PrivateAPI)

#pragma mark -
#pragma mark ImageEntriesView (View Management)

- (void)moveLeft {
    if ([self canAddRightView]) {
        self.rightMostIndex++;
        Capture* capture = [self.entries objectAtIndex:self.rightMostIndex];
        [self.entriesStreamView addViewToRight:[ImageEntryView withFrame:self.frame capture:capture]];
    }
    if ([self canRemoveLeftView]) {
        [self.entriesStreamView removeFirstView];
        self.leftMostIndex++;
    }
}

- (void)moveRight {
    if ([self canAddLeftView]) {
        self.leftMostIndex--;
        Capture* capture = [self.entries objectAtIndex:self.leftMostIndex];
        [self.entriesStreamView addViewToLeft:[ImageEntryView withFrame:self.frame capture:capture]];
    }
    if ([self canRemoveRightView]) {
        [self.entriesStreamView removeLastView];
        self.rightMostIndex--;
    }
}

- (BOOL)canAddRightView {
    NSInteger rightWidth = self.rightMostIndex - self.inViewIndex;
    return (self.rightMostIndex < [self entryCount] - 1 && rightWidth < LOADED_ENTRIES_BUFFER);
}

- (BOOL)canRemoveRightView {
    NSInteger rightWidth = self.rightMostIndex - self.inViewIndex;
    return (self.rightMostIndex > 0 && rightWidth > LOADED_ENTRIES_BUFFER);
}

- (BOOL)canAddLeftView {
    NSInteger leftWidth = self.inViewIndex - self.leftMostIndex;
    return (self.leftMostIndex > 0 && leftWidth < LOADED_ENTRIES_BUFFER); 
}

- (BOOL)canRemoveLeftView {
    NSInteger leftWidth = self.inViewIndex - self.leftMostIndex;
    return (self.leftMostIndex < [self entryCount] - 1 && leftWidth > LOADED_ENTRIES_BUFFER); 
}

- (void)removeEntry:(ImageEntryView*)__entry {
    [self.entries removeObject:__entry.capture];
    if (self.inViewIndex == self.rightMostIndex && self.inViewIndex != 0) {
        self.inViewIndex--;
    }
    if (self.rightMostIndex > 0) {
        self.rightMostIndex--;
    }
    [self moveLeft];
    [self moveRight];
}

- (void)loadEntries {
    if ([self.delegate respondsToSelector:@selector(loadEntries)]) {
        self.entries = [self.delegate loadEntries];
        for (int i = 0; i < [self.entries count]; i++) {
            Capture* capture = [self.entries objectAtIndex:i];
            NSInteger rightWidth = self.rightMostIndex - self.inViewIndex;
            if (rightWidth < LOADED_ENTRIES_BUFFER) {
                if (i > 0) {
                    self.rightMostIndex++;
                }
                [self.entriesStreamView addViewToRight:[ImageEntryView withFrame:self.frame capture:capture]];
            }
        }
    }
}

#pragma mark -
#pragma mark StreamOfViewsDelegate

- (void)didDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(dragEntries:)]) {
        [self.delegate dragEntries:_drag];
    }
}

- (void)didDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(dragEntries:)]) {
        [self.delegate dragEntries:_drag];
    }
}

- (void)didReleaseUp:(CGPoint)_location {
    if ([self.delegate respondsToSelector:@selector(releaseEntries)]) {
        [self.delegate releaseEntries];
    }
}

- (void)didReleaseDown:(CGPoint)_location {
    if ([self.delegate respondsToSelector:@selector(releaseEntries)]) {
        [self.delegate releaseEntries];
    }
}

- (void)didSwipeUp:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(transitionUpFromEntries)]) {
        [self.delegate transitionUpFromEntries];
    }
}

- (void)didSwipeDown:(CGPoint)_location withVelocity:(CGPoint)_velocity {
    if ([self.delegate respondsToSelector:@selector(transitionDownFromEntries)]) {
        [self.delegate transitionDownFromEntries];
    }
}

- (void)didReachMaxDragUp:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
    if ([self.delegate respondsToSelector:@selector(transitionUpFromEntries)]) {
        [self.delegate transitionUpFromEntries];
    }
}

- (void)didReachMaxDragDown:(CGPoint)_drag from:(CGPoint)_location withVelocity:(CGPoint)_velocity {    
    if ([self.delegate respondsToSelector:@selector(transitionDownFromEntries)]) {
        [self.delegate transitionDownFromEntries];
    }
}

- (void)didRemoveAllViews {
    if ([self.delegate respondsToSelector:@selector(didRemoveAllEntries:)]) {
        [self.delegate didRemoveAllEntries:self];
    }
}

- (void)didMoveRight {
    self.inViewIndex--;
    [self moveRight];
}

- (void)didMoveLeft {
    self.inViewIndex++;
    [self moveLeft];
}

#pragma mark -
#pragma mark DiagonalGestrureRecognizerDelegate

-(void)didCheck {
    ImageEntryView* entry = (ImageEntryView*)[self.entriesStreamView displayedView];
    [self.entriesStreamView moveDisplayedViewDownAndRemove];
    [self removeEntry:entry];
}

-(void)didDiagonalSwipe {
    ImageEntryView* entry = (ImageEntryView*)[self.entriesStreamView displayedView];
    [self.entriesStreamView moveDisplayedViewDiagonallyAndRemove];
    [self removeEntry:entry];
}

#pragma mark -
#pragma mark ImageEntryViewDelegate

- (void)didSingleTapImage {
    if ([self.delegate respondsToSelector:@selector(didSingleTapEntries:)]) {
        [self.delegate didSingleTapEntries:self];
    }
}

- (void)touchEnabled:(BOOL)_enabled {
    [self.entriesStreamView enabled:_enabled];
    self.diagonalGestures.enabled = _enabled;
}

@end
