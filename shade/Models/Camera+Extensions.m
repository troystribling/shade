//
//  Camera+Extensions.m
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "Camera+Extensions.h"

@interface Camera (PrivateAPI)

@end

@implementation Camera (Extensions)

+ (NSArray*)loadCameras {
    NSString* cameraFile = [[NSBundle  mainBundle] pathForResource:@"Cameras" ofType:@"plist"];
    NSArray* configuredCameras = [[NSDictionary dictionaryWithContentsOfFile:cameraFile] objectForKey:@"cameras"];
    NSInteger configuredCameraCount = [configuredCameras count];
    for (int i = 0; i < configuredCameraCount; i++) {
        NSDictionary* configuredCamera = [configuredCameras objectAtIndex:i];
        Camera *camera = [self findFirstWithCameraId:i];
        if (camera == nil) {
            camera = [self create];
            camera.identifier  = [configuredCamera objectForKey:@"identifier"];
            camera.purchased = [configuredCamera objectForKey:@"purchased"];
        }
        camera.name             = [configuredCamera objectForKey:@"name"];
        camera.hasParameter     = [configuredCamera objectForKey:@"hasParameter"];
        camera.maximumValue     = [configuredCamera objectForKey:@"maximumValue"];
        camera.minimumValue     = [configuredCamera objectForKey:@"minimumValue"];
        camera.value            = [configuredCamera objectForKey:@"value"];
        [camera save];
    }
    return [self findAll];
}

+ (NSDictionary*)loadCameraParameters {
    NSString* cameraFile = [[NSBundle  mainBundle] pathForResource:@"CameraFilterParameters" ofType:@"plist"];
    return [[NSDictionary dictionaryWithContentsOfFile:cameraFile] objectForKey:@"CameraFilterParameters"];
}

#pragma mark -
#pragma mark Queries

+ (Camera*)findFirstWithCameraId:(NSInteger)__cameraId inContext:(NSManagedObjectContext *)__context {
    return [self findFirstWithPredicate:[NSPredicate predicateWithFormat:@"cameraId == %@", [NSNumber numberWithInt:__cameraId]] inContext:__context];
}

+ (Camera*)findFirstWithCameraId:(NSInteger)__cameraId {
    return [self findFirstWithCameraId:__cameraId inContext:[DataManager instance].managedObjectContext];
}

#pragma mark -
#pragma mark Private API


@end
