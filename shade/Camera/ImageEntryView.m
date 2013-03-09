//
//  ImageEntryView.m
//  photio
//
//  Created by Troy Stribling on 4/5/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "ImageEntryView.h"
#import "Capture+Extensions.h"
#import "ViewGeneral.h"

@interface ImageEntryView ()
@end

@implementation ImageEntryView


#pragma mark -
#pragma mark ImageEntryView PrivateAPI

#pragma mark -
#pragma mark ImageEntryView

+ (id)withCapture:(Capture*)__capture andImage:(UIImage*)__image {
    return  [[ImageEntryView alloc] initWithCapture:__capture andImage:__image];
}

- (id)initWithCapture:(Capture*)__capture andImage:(UIImage*)__image {
    if ((self = [super initWithImage:__image])) {
        self.capture = __capture;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark -
#pragma mark ImageEditViewController


@end
