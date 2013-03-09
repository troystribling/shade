//
//  ImageEntryView.h
//  photio
//
//  Created by Troy Stribling on 4/5/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol ImageEntryViewDelegate;

@class Capture;

@interface ImageEntryView : UIImageView

@property(nonatomic, strong) Capture*   capture;

+ (id)withCapture:(Capture*)_capture andImage:(UIImage*)__image;
- (id)initWithCapture:(Capture*)_capture andImage:(UIImage*)__image;

@end
