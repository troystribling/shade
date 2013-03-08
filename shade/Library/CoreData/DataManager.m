//
//  DataManager.m
//  EventChainIOSCore
//
//  Created by Troy Stribling on 10/2/12.
//  Copyright (c) 2012 GNMA. All rights reserved.
//

#import "DataManager.h"
#import "UIAlertView+Extensions.h"

static DataManager* thisDataManager = nil;

@interface DataManager ()

- (NSManagedObjectContext*)managedObjectContext;
- (NSManagedObjectModel*)managedObjectModel;
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator;
- (NSURL*)applicationDocumentsDirectory;

@end

@implementation DataManager

@synthesize managedObjectContext        = __managedObjectContext;
@synthesize managedObjectModel          = __managedObjectModel;
@synthesize persistentStoreCoordinator  = __persistentStoreCoordinator;

#pragma mark -
#pragma mark DataContextManager

+ (DataManager*)create {
    if (thisDataManager == nil) {
        thisDataManager = [[self alloc] init];
    }
    return thisDataManager;
}

+ (DataManager*)instance {
    return thisDataManager;
}

+ (void)waitForSavesToFinish {
    dispatch_sync([DataManager instance].backgroundQueue, ^{});
}

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundQueue = dispatch_queue_create("com.imaginaryproducts.dataManager", NULL);
    }
    return self;
}

- (NSManagedObjectContext*)createContext {
    NSManagedObjectContext* newMoc = [[NSManagedObjectContext alloc] init];
    [newMoc setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    return newMoc;
}

- (void)mergeChangesFromContextDidSaveNotification:(NSNotification*)notification  {
    [__managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)performInBackground:(void(^)(NSManagedObjectContext* context))operation {
    dispatch_async(self.backgroundQueue, ^{
        NSManagedObjectContext *backgroundContext = [self createContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFromContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:backgroundContext];
        operation(backgroundContext);
    });
}

- (void)waitForQueueToEmpty {
    dispatch_sync(self.backgroundQueue, ^{});
}

- (BOOL)save {
    return [self saveInContext:__managedObjectContext];
}

- (BOOL)saveInContext:(NSManagedObjectContext*)_context {
    NSError *error = nil;
    BOOL status = YES;
    if (![_context save:&error]) {
        status = NO;
    }
    return status;
}

- (BOOL)destroy:(NSManagedObject*)_object {
    return [self destroy:_object inContext:__managedObjectContext];
}

- (BOOL)destroy:(NSManagedObject*)_object inContext:(NSManagedObjectContext*)_context {
    [_context deleteObject:_object];
    return [self saveInContext:_context];
}

- (NSUInteger)count:(NSFetchRequest*)_fetchRequest {
    return [self count:_fetchRequest inContext:__managedObjectContext];
}

- (NSUInteger)count:(NSFetchRequest*)_fetchRequest inContext:(NSManagedObjectContext*)_context {
    NSError* error;
    NSUInteger count = [_context countForFetchRequest:_fetchRequest error:&error];
    if (count == NSNotFound) {
        [UIAlertView alertOnError:error];
        abort();
    }
    return count;
}

- (NSArray*)fetch:(NSFetchRequest*)_fetchRequest {
    return [self fetch:_fetchRequest inContext:__managedObjectContext];
}

- (NSArray*)fetch:(NSFetchRequest*)_fetchRequest inContext:(NSManagedObjectContext*)_context {
    NSError* error;
    NSArray* fetchResults = [_context executeFetchRequest:_fetchRequest error:&error];
    if (fetchResults == nil) {
        [UIAlertView alertOnError:error];
        abort();
    }
    return fetchResults;
}

- (id)fetchFirst:(NSFetchRequest*)_fetchRequest {
    return [self fetchFirst:_fetchRequest inContext:__managedObjectContext];
}

- (id)fetchFirst:(NSFetchRequest*)_fetchRequest inContext:(NSManagedObjectContext*)_context {
    id fetchResult = nil;
    _fetchRequest.fetchLimit = 1;
    NSArray* fetchResults = [self fetch:_fetchRequest inContext:_context];
    if ([fetchResults count] > 0) {
        fetchResult = [fetchResults objectAtIndex:0];
    }
    return fetchResult;
}

- (id)fetchWithID:(NSManagedObjectID*)objectID inContext:(NSManagedObjectContext*)context {
    NSError* error = nil;
    NSManagedObject *fetchResult = [context existingObjectWithID:objectID error:&error];
    if (error) {
        [UIAlertView alertOnError:error];
        abort();
    }
    return fetchResult;
}

- (id)fetchWithID:(NSManagedObjectID*)objectID {
    return [self fetchWithID:objectID inContext:__managedObjectContext];
}

#pragma mark -
#pragma mark DataContextManager PrivateAPI

- (NSManagedObjectContext*)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSLog(@"%@", [NSBundle mainBundle]);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:self.persistantStoreName];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return __persistentStoreCoordinator;
}

- (NSURL*)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
