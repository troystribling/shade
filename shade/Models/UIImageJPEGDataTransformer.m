//
//  UIImageJPEGDataTransformer.m
//  photio
//
//  Created by Troy Stribling on 6/25/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "UIImageJPEGDataTransformer.h"

@implementation UIImageJPEGDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}

- (id)transformedValue:(id)value {
	return UIImageJPEGRepresentation(value, 1.0);
}

- (id)reverseTransformedValue:(id)value {
	return [[UIImage alloc] initWithData:value];
}

@end
