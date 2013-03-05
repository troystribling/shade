//
//  DataManager.h
//  EventChainIOSCore
//
//  Created by Troy Stribling on 10/2/12.
//  Copyright (c) 2012 GNMA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObject;
@class NSManagedObjectContext;
@class NSManagedObjectID;
@class NSFetchRequest;

@interface DataManager : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel*           managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext*         managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator*   persistentStoreCoordinator;
@property (nonatomic, strong)           NSURL*                          modelURL;
@property (nonatomic, strong)           NSString*                       persistantStoreName;
@property (nonatomic, assign)           dispatch_queue_t                backgroundQueue;


+ (DataManager*)create;
+ (DataManager*)instance;
+ (void)waitForSavesToFinish;

- (NSManagedObjectContext*)createContext;
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification*)notification;
- (void)performInBackground:(void(^)(NSManagedObjectContext* contexr))operation;

- (BOOL)save;
- (BOOL)saveInContext:(NSManagedObjectContext*)_context;

- (BOOL)destroy:(NSManagedObject*)_object;
- (BOOL)destroy:(NSManagedObject*)_object inContext:(NSManagedObjectContext*)_context;

- (NSUInteger)count:(NSFetchRequest*)_fetchRequest;
- (NSUInteger)count:(NSFetchRequest*)_fetchRequest inContext:(NSManagedObjectContext*)_context;

- (NSArray*)fetch:(NSFetchRequest*)_fetchRequest;
- (NSArray*)fetch:(NSFetchRequest*)_fetchRequest inContext:(NSManagedObjectContext*)_context;

- (id)fetchFirst:(NSFetchRequest*)_fetchRequest;
- (id)fetchFirst:(NSFetchRequest*)_fetchRequest inContext:(NSManagedObjectContext*)_context;

- (id)fetchWithID:(NSManagedObjectID*)objectID inContext:(NSManagedObjectContext*)context;
- (id)fetchWithID:(NSManagedObjectID*)objectID;

@end
