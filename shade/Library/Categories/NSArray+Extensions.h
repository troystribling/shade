//
//  NSArray+Extensions.h
//  photio
//
//  Created by Troy Stribling on 4/25/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSArray (Extensions)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end
