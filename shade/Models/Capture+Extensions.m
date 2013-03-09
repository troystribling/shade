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

+ (void)createForImage:(UIImage*)__image {
    Capture *capture = [Capture create];
    [[ViewGeneral instance] addCapture:capture andImage:__image];
}

@end
