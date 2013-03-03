//
//  NSObject+Extensions.m
//  photio
//
//  Created by Troy Stribling on 5/5/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Extensions.h"

@implementation NSObject (Extensions)

- (NSString*)className {
    return [NSString stringWithUTF8String:(char*)class_getName([self class])];
}

@end
