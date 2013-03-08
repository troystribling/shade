//
//  PassThoughFilter.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "PassThoughFilter.h"

@implementation PassThoughFilter

- (GPUImageOutput<GPUImageInput>*)createFilter {
    return [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"PassThrough"];
}

@end
