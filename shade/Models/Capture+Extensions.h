//
//  Capture+Extensions.h
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "DataManager.h"
#import "NSManagedObject+DataManager.h"
#import "Capture.h"

@interface Capture (Extensions)

+ (UIImage*)scaleImage:(UIImage*)__image toFrame:(CGRect)__frame;
- (NSString*)imageID;

@end
