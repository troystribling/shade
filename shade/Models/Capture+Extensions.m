//
//  Capture+Extensions.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "Capture+Extensions.h"
#import "ViewGeneral.h"

@implementation Capture (Extensions)

- (NSString*)imageID {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYDDD-HHmmssSSS"];
    return [dateFormatter stringFromDate:self.createdAt];
}

@end
