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

+ (id)withFrame:(CGRect)_frame capture:(Capture*)_capture;
- (id)initWithFrame:(CGRect)_frame capture:(Capture*)_capture;

@end
