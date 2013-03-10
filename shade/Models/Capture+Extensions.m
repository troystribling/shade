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
    [capture save];
    ViewGeneral *viewGeneral = [ViewGeneral instance];
    [viewGeneral addCapture:capture andImage:__image];
    [viewGeneral writeImage:__image withId:[NSString stringWithFormat:@"%@", capture.createdAt]];
}

@end
