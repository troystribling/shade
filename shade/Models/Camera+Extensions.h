//
//  Camera+Extensions.h
//  shade
//
//  Created by Troy Stribling on 3/3/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "DataManager.h"
#import "NSManagedObject+DataManager.h"
#import "Camera.h"

typedef enum {
    CameraIdIPhone,
    CameraIdInstant,
    CameraIdBox,
    CameraIdPlastic
} CameraId;

@interface Camera (Extensions)

+ (NSArray*)loadCameras;
+ (NSDictionary*)loadCameraParameters;

+ (Camera*)findFirstWithCameraId:(CameraId)__cameraId inContext:(NSManagedObjectContext*)__context;
+ (Camera*)findFirstWithCameraId:(CameraId)__cameraId;
+ (NSArray*)findAllOrderedByIdentifier;

@end
