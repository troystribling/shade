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
#pragma mark ImageEntryView

+ (id)withCapture:(Capture*)__capture andImage:(UIImage*)__image {
    return  [[ImageEntryView alloc] initWithCapture:__capture andImage:__image];
}

+ (id)withFrame:(CGRect)__frame capture:(Capture*)__capture andImageData:(NSData*)__imageData {
    return [[ImageEntryView alloc] initWithFrame:__frame capture:__capture andImageData:__imageData];
}

- (id)initWithCapture:(Capture*)__capture andImage:(UIImage*)__image {
    self = [super initWithImage:__image];
    if (self) {
        self.capture = __capture;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)__frame capture:(Capture*)__capture andImageData:(NSData*)__imageData {
    self = [super initWithFrame:__frame];
    if (self) {
        self.capture = __capture;
        self.contentMode = UIViewContentModeCenter;
        self.clipsToBounds = YES;
        UIImage *imageFromData = [[UIImage alloc] initWithData:__imageData];
        self.image = [UIImage imageWithCGImage:imageFromData.CGImage scale:[[UIScreen mainScreen] scale] orientation:imageFromData.imageOrientation];
    }
    return self;
}

- (id)clone {
    Capture *clonedCapture = [Capture findWithID:self.capture.objectID];
    return [self.class withCapture:clonedCapture andImage:[UIImage imageWithData:UIImageJPEGRepresentation(self.image, 1.0f)]];
}

#pragma mark -
#pragma mark ImageEntryView PrivateAPI

- (UIImage*)scaleImage:(UIImage*)_image {
    return [Capture scaleImage:_image toFrame:self.frame];
}

#pragma mark -
#pragma mark ImageEditViewController


@end
