//
//  ProgressView.h
//  photio
//
//  Created by Troy Stribling on 5/14/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoundedCornersView;

@interface ProgressView : UIView {
}

@property(nonatomic, strong) RoundedCornersView*    displayView;
@property(nonatomic, strong) UIView*                backgroundView;
@property(nonatomic, strong) UILabel*               displayMessage;

+ (id)progressView;
- (void)progressWithMessage:(NSString*)_message inView:(UIView*)_containerView;
- (void)remove;


@end
