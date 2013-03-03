//
//  NSArray+Extensions.m
//  photio
//
//  Created by Troy Stribling on 4/25/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end