//
//  Camera.h
//  shade
//
//  Created by Troy Stribling on 3/8/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Camera : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * hasParameter;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * maximumValue;
@property (nonatomic, retain) NSNumber * minimumValue;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * purchased;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * cameraId;

@end
