//
//  UIImage+Extensions.m
//  photio
//
//  Created by Troy Stribling on 5/27/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "UIImage+Extensions.h"

@implementation UIImage (Extensions)

+ (UIImage*)blankImage:(CGSize)_size {
    return [self blankImage:_size withColor:[UIColor whiteColor]];
}

+ (UIImage*)blankImage:(CGSize)_size withColor:(UIColor*)_color {
    UIGraphicsBeginImageContext(_size);	
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, _size.width, _size.height));
    UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

@end
