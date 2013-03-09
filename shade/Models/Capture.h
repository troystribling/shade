//
//  Capture.h
//  shade
//
//  Created by Troy Stribling on 3/9/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Capture : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) NSDate * updatedAt;

@end
