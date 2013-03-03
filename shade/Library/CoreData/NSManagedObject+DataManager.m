//
//  NSManagedObject+DataManager.m
//  EventChainIOSCore
//
//  Created by Troy Stribling on 10/3/12.
//  Copyright (c) 2012 GNMA. All rights reserved.
//

#import "DataManager.h"
#import "NSObject+Extensions.h"
#import "NSManagedObject+DataManager.h"

@interface NSManagedObject (DataManagerPrivateAPI)

@end

@implementation NSManagedObject (DataManager)

#pragma mark -
#pragma Fetch Request

+ (NSEntityDescription*)entityInContext:(NSManagedObjectContext*)context {
    return [NSEntityDescription entityForName:[self className] inManagedObjectContext:context];
}

+ (NSFetchRequest*)fetchRequestInContext:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [self entityInContext:context];
    [fetchRequest setEntity:entity];
    return fetchRequest;
}

#pragma mark -
#pragma mark findAll

+ (NSArray*)findAllInContext:(NSManagedObjectContext*)context {
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    return [self findAllWithPredicate:nil andSortDescriptors:sortDescriptors inContext:context];
}

+ (NSArray*)findAll {
    return [self findAllInContext:[DataManager instance].managedObjectContext];
}

+ (NSArray*)findAllWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context {
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    return [self findAllWithPredicate:predicate andSortDescriptors:sortDescriptors inContext:context];
}

+ (NSArray*)findAllWithPredicate:(NSPredicate*)predicate {
    return [self findAllWithPredicate:predicate inContext:[DataManager instance].managedObjectContext];
}

+ (NSArray*)findAllWithSortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context {
    return [self findAllWithPredicate:nil andSortDescriptors:sortDescriptors inContext:context];
}

+ (NSArray*)findAllWithSortDescriptors:(NSArray*)sortDescriptors {
    return [self findAllWithSortDescriptors:sortDescriptors inContext:[DataManager instance].managedObjectContext];
}

+ (NSArray*)findAllWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [self fetchRequestInContext:context];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    return [[DataManager instance] fetch:fetchRequest inContext:context];
}

+ (NSArray*)findAllWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescriptors {
    return [self findAllWithPredicate:predicate andSortDescriptors:sortDescriptors inContext:[DataManager instance].managedObjectContext];
}

#pragma mark -
#pragma mark findFirst

+ (id)findFirstInContext:(NSManagedObjectContext*)context {
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    return [self findFirstWithPredicate:nil andSortDescriptors:sortDescriptors inContext:context];
}

+ (id)findFirst {
    return [self findFirstInContext:[DataManager instance].managedObjectContext];
}

+ (id)findFirstWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context {
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    return [self findFirstWithPredicate:predicate andSortDescriptors:sortDescriptors inContext:context];
}

+ (id)findFirstWithPredicate:(NSPredicate*)predicate {
    return [self findFirstWithPredicate:predicate inContext:[DataManager instance].managedObjectContext];
}

+ (id)findFirstWithSortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context {
    return [self findFirstWithPredicate:nil andSortDescriptors:sortDescriptors inContext:context];
}

+ (id)findFirstWithSortDescriptors:(NSArray*)sortDescriptors {
    return [self findFirstWithSortDescriptors:sortDescriptors inContext:[DataManager instance].managedObjectContext];
}

+ (id)findFirstWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [self fetchRequestInContext:context];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    return [[DataManager instance] fetchFirst:fetchRequest inContext:context];
}

+ (id)findFirstWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray*)sortDescriptors {
    return [self findFirstWithPredicate:predicate andSortDescriptors:sortDescriptors inContext:[DataManager instance].managedObjectContext];
}

#pragma mark -
#pragma mark fetchWithID

+ (id)findWithID:(NSManagedObjectID*)objectID inContext:(NSManagedObjectContext*)context {
    return [[DataManager instance] fetchWithID:objectID inContext:context];
}

+ (id)findWithID:(NSManagedObjectID*)objectID {
    return [self findWithID:objectID inContext:[DataManager instance].managedObjectContext];
}

#pragma mark -
#pragma mark count

+ (NSInteger)countInContext:(NSManagedObjectContext*)context {
    return [self countWithPredicate:nil inContext:context];
}

+ (NSInteger)count {
    return [self countInContext:[DataManager instance].managedObjectContext];
}

+ (NSInteger)countWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context {
    NSFetchRequest *fetchRequest = [self fetchRequestInContext:context];
    [fetchRequest setPredicate:predicate];
    return [[DataManager instance] count:fetchRequest inContext:context];
}

+ (NSInteger)countWithPredicate:(NSPredicate*)predicate {
    return [self countWithPredicate:predicate inContext:[DataManager instance].managedObjectContext];
}

#pragma mark -
#pragma mark exists

+ (BOOL)existsInContext:(NSManagedObjectContext*)context {
    return [self existsWithPredicate:nil inContext:context];
}

+ (BOOL)exists {
    return [self existsInContext:[DataManager instance].managedObjectContext];
}

+ (BOOL)existsWithPredicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext*)context {
    NSInteger count = [self countWithPredicate:predicate inContext:context];
    if (count > 0) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)existsWithPredicate:(NSPredicate*)predicate {
    return [self existsWithPredicate:predicate inContext:[DataManager instance].managedObjectContext];
}

#pragma mark -
#pragma mark create

+ (id)createInContext:(NSManagedObjectContext*)context {
    NSDate *now = [NSDate date];
    id model = [NSEntityDescription  insertNewObjectForEntityForName:[self className] inManagedObjectContext:context];
    [model performSelector:@selector(setCreatedAt:) withObject:now];
    [model performSelector:@selector(setUpdatedAt:) withObject:now];
    return model;
}

+ (id)create {
    return [self createInContext:[DataManager instance].managedObjectContext];
}

#pragma mark -
#pragma mark save

- (BOOL)save {
    return [[DataManager instance] saveInContext:self.managedObjectContext];
}

#pragma mark -
#pragma mark destroy

- (BOOL)destroy {
    return [[DataManager instance] destroy:self inContext:self.managedObjectContext];
}

- (void)discard {
    [self.managedObjectContext reset];
}

#pragma mark -
#pragma mark PrivateAPI

@end

@implementation NSManagedObject (DataManagerPrivateAPI)

@end