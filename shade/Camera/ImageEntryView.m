//
//  ImageEntryView.m
//  photio
//
//  Created by Troy Stribling on 4/5/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "ImageEntryView.h"
#import "Capture+Extensions.h"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ImageEntryView (PrivateAPI)

@end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ImageEntryView


#pragma mark -
#pragma mark ImageEntryView PrivateAPI

#pragma mark -
#pragma mark ImageEntryView

+ (id)withFrame:(CGRect)__frame capture:(Capture*)__capture {
    return  [[ImageEntryView alloc] initWithFrame:__frame capture:__capture];
}

- (id)initWithFrame:(CGRect)__frame capture:(Capture*)__capture {
    if ((self = [super initWithFrame:(CGRect)__frame])) {
        self.capture = __capture;
    }
    return self;
}

#pragma mark -
#pragma mark ImageEditViewController


@end
