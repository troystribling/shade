//
//  Capture+Extensions.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "Capture+Extensions.h"
#import "ViewGeneral.h"
#import "UIImage+Resize.h"

@implementation Capture (Extensions)

+ (UIImage*)scaleImage:(UIImage*)__image toFrame:(CGRect)__frame {
    CGFloat imageAspectRatio = __image.size.height / __image.size.width;
    CGFloat scaledImageWidth = __frame.size.width;
    CGFloat scaledImageHeight = MAX(scaledImageWidth * imageAspectRatio, __frame.size.height);
    if (imageAspectRatio < 1.0) {
        scaledImageHeight = imageAspectRatio * scaledImageWidth;
    }
    CGSize scaledImageSize = CGSizeMake(scaledImageWidth, scaledImageHeight);
    return [__image scaleToSize:scaledImageSize];
}

- (NSString*)imageID {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYDDD-HHmmssSSS"];
    return [dateFormatter stringFromDate:self.createdAt];
}

@end
