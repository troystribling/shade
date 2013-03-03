//
//  UIView+Extensions.m
//  photio
//
//  Created by Troy Stribling on 5/5/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "UIView+Extensions.h"
#import "NSObject+Extensions.h"

@implementation UIView (Extensions)

+ (UIView*)loadView:(Class)_viewClass { 
    NSString* nibName = [_viewClass className];
    UIView* view = nil;
    NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil]; 
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator]; 
    NSObject* nibItem = nil; 
    while ((nibItem = [nibEnumerator nextObject]) != nil) { 
        if ([nibItem isKindOfClass:_viewClass]) { 
            view = (UIView*)nibItem; 
            break; 
        } 
    } 
	return view; 
} 

@end
