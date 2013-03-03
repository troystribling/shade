//
//  NSManagedObject+DataManager.h
//  EventChainIOSCore
//
//  Created by Troy Stribling on 10/3/12.
//  Copyright (c) 2012 GNMA. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DataManager)

+ (NSEntityDescription*)entityInContext:(NSManagedObjectContext*)context;
+ (NSFetchRequest*)fetchRequestInContext:(NSManagedObjectContext*)context;

+ (NSArray*)findAllInContext:(NSManagedObjectContext*)context;
+ (NSArray*)findAll;
+ (NSArray*)findAllWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context;
+ (NSArray*)findAllWithPredicate:(NSPredicate*)predicate;
+ (NSArray*)findAllWithSortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context;
+ (NSArray*)findAllWithSortDescriptors:(NSArray*)sortDescriptors;
+ (NSArray*)findAllWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context;
+ (NSArray*)findAllWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescriptors;

+ (id)findFirstInContext:(NSManagedObjectContext*)context;
+ (id)findFirst;
+ (id)findFirstWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context;
+ (id)findFirstWithPredicate:(NSPredicate*)predicate;
+ (id)findFirstWithSortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context;
+ (id)findFirstWithSortDescriptors:(NSArray*)sortDescriptors;
+ (id)findFirstWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context;
+ (id)findFirstWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescriptors;

+ (id)findWithID:(NSManagedObjectID*)objectID inContext:(NSManagedObjectContext*)context;
+ (id)findWithID:(NSManagedObjectID*)objectID;

+ (NSInteger)countInContext:(NSManagedObjectContext*)context;
+ (NSInteger)count;
+ (NSInteger)countWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context;
+ (NSInteger)countWithPredicate:(NSPredicate*)predicate;

+ (BOOL)existsInContext:(NSManagedObjectContext*)context;
+ (BOOL)exists;
+ (BOOL)existsWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context;
+ (BOOL)existsWithPredicate:(NSPredicate*)predicate;

+ (id)createInContext:(NSManagedObjectContext*)context;
+ (id)create;
- (BOOL)save;
- (BOOL)destroy;
- (void)discard;

@end
