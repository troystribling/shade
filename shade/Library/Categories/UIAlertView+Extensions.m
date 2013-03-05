//
//  UIAlertView+Extensions.m
//  EventChainIOSCore
//
//  Created by Troy Stribling on 9/13/12.
//  Copyright (c) 2012 GNMA. All rights reserved.
//

#import "UIAlertView+Extensions.h"

@implementation UIAlertView (Extensions)

+ (void)alertOnError:(NSError*)error {
    NSLog(@"Had and Error %@, %@", error, [error userInfo]);
    [[[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedFailureReason] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title") otherButtonTitles:nil] show];
}

+ (void)showMessage:(NSString*)msg {
    [[[UIAlertView alloc] initWithTitle:msg
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                      otherButtonTitles:nil] show];
}

@end
