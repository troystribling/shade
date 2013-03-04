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
    CameraTypeIPhone,
    CameraTypeInstant,
    CameraTypeBox,
    CameraTypePlastic
} CameraType;

@interface Camera (Extensions)

+ (NSArray*)loadCameras;
+ (NSDictionary*)loadCameraParameters;

+ (Camera*)findFirstWithCameraId:(NSInteger)__cameraId inContext:(NSManagedObjectContext *)context;
+ (Camera*)findFirstWithCameraId:(NSInteger)__cameraId;

@end
