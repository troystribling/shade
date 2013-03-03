//
//  UIImage+Extensions.h
//  photio
//
//  Created by Troy Stribling on 5/27/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Extensions)

+ (UIImage*)blankImage:(CGSize)_size;
+ (UIImage*)blankImage:(CGSize)_size withColor:(UIColor*)_color;

@end
