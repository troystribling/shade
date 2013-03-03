//
//  Capture.h
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Capture : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedt;
@property (nonatomic, retain) NSString * imageName;

@end
