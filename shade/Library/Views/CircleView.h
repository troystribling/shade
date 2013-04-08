//
//  CircleView.h
//  shade
//
//  Created by Troy Stribling on 4/6/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleView : UIView

+ (id)withRadius:(float)__radius centeredAt:(CGPoint)__center;
- (id)initWithRadius:(float)__radius centeredAt:(CGPoint)__center;

@end
