//
//  UIAlertView+Extensions.h
//  EventChainIOSCore
//
//  Created by Troy Stribling on 9/13/12.
//  Copyright (c) 2012 GNMA. All rights reserved.
//

#import <UIKit/UIkit.h>

@interface UIAlertView (Extensions)

+ (void)alertOnError:(NSError*)error;
+ (void)showMessage:(NSString*)msg;

@end
