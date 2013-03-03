//
//  UITableViewCell+Extensions.m
//  photio
//
//  Created by Troy Stribling on 5/20/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "UITableViewCell+Extensions.h"
#import "NSObject+Extensions.h"

@implementation UITableViewCell (Extensions)

+ (UITableViewCell*)loadCell:(Class)_cellClass { 
    NSString* nibName = [_cellClass className];
    UITableViewCell* cell = nil;
    NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil]; 
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator]; 
    NSObject* nibItem = nil; 
    while ((nibItem = [nibEnumerator nextObject]) != nil) { 
        if ([nibItem isKindOfClass:_cellClass]) { 
            cell = (UITableViewCell*)nibItem; 
            if ([cell.reuseIdentifier isEqualToString:nibName]) 
                break; 
            else 
                cell = nil; 
        } 
    } 
	return cell; 
} 


@end
