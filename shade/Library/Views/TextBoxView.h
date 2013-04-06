//
//  TextBoxView.h
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BorderedView;

@interface TextBoxView : UIView

@property(nonatomic, strong) BorderedView   *backgroundView;
@property(nonatomic, strong) UILabel        *textLabel;

+ (id)withText:(NSString*)__text andWidth:(float)__width;
+ (id)withText:(NSString*)__text;
- (id)initWithText:(NSString*)__text constrainedToWidth:(float)__width;

@end
