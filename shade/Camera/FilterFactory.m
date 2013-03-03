//
//  FilterFactory.m
//  photio
//
//  Created by Troy Stribling on 5/18/12.
//  Copyright (c) 2012 imaginaryProducts. All rights reserved.
//

#import "FilterFactory.h"
#import "CameraFactory.h"
#import "GPUImage.h"

#import "DataContextManager.h"
#import "FilterPalette.h"

/////////////////////////////////////////////////////////////////////////////////////////
static FilterFactory* thisFilterFactory = nil;

/////////////////////////////////////////////////////////////////////////////////////////
@interface FilterFactory (PrivateAPI)

+ (FilterPalette*)filterPalette:(NSNumber*)_filterPalette;
+ (NSArray*)loadFilterClasses;
+ (NSArray*)loadFilters;
+ (UIImage*)outputImageForFilter:(GPUImageOutput<GPUImageInput>*)_filter andImage:(UIImage*)_image;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@interface FilterFactory (Filters)

+ (UIImage*)applyBrightnessFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyRedColorFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyGreenColorFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyBlueColorFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyContrastFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applySaturationFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyVignetteFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyInstantFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyPixelFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyBoxFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;
+ (UIImage*)applyPlasticFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image;

@end

/////////////////////////////////////////////////////////////////////////////////////////
@implementation FilterFactory

@synthesize loadedFilterPalettes, loadedFilters;

#pragma mark - 
#pragma mark FilterFactory PrivateApi

+ (FilterPalette*)filterPalette:(NSNumber*)_filterPalette {
    DataContextManager* contextManager = [DataContextManager instance];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"FilterPalette" inManagedObjectContext:contextManager.mainObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"filterPaletteId == %@", _filterPalette]];
    [fetchRequest setFetchLimit:1];
    NSArray* fetchResults = [contextManager fetch:fetchRequest];
    return [fetchResults objectAtIndex:0];
}

+ (NSArray*)loadFilterPalettes {
    DataContextManager* contextManager = [DataContextManager instance];
    
    NSString* filterPaletteFile = [[NSBundle  mainBundle] pathForResource:@"FilterPalettes" ofType:@"plist"];
    NSArray* configuredFilterClasses = [[NSDictionary dictionaryWithContentsOfFile:filterPaletteFile] objectForKey:@"filterPalettes"];
    NSInteger configuredFilterClassCount = [configuredFilterClasses count];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* filterPaletteEntity = [NSEntityDescription entityForName:@"FilterPalette" inManagedObjectContext:contextManager.mainObjectContext];
    [fetchRequest setEntity:filterPaletteEntity];   
    NSInteger filterPaletteCount = [contextManager count:fetchRequest];
    
    if (filterPaletteCount < configuredFilterClassCount) {
        for (int i = 0; i < (configuredFilterClassCount - filterPaletteCount); i++) {
            FilterPalette* filterPalette = (FilterPalette*)[NSEntityDescription insertNewObjectForEntityForName:@"FilterPalette" inManagedObjectContext:contextManager.mainObjectContext];
            NSDictionary* configuredFilterClass = [configuredFilterClasses objectAtIndex:(filterPaletteCount + i)];
            filterPalette.name              = [configuredFilterClass objectForKey:@"name"];
            filterPalette.filterPaletteId   = [configuredFilterClass objectForKey:@"filterPaletteId"];
            filterPalette.imageFilename     = [configuredFilterClass objectForKey:@"imageFilename"];
            filterPalette.hidden            = [configuredFilterClass objectForKey:@"hidden"];
            filterPalette.usageRate         = [NSNumber numberWithFloat:0.0];
            filterPalette.usageCount        = [NSNumber numberWithFloat:0.0];
            [contextManager save];
        }
    }
    
    return [contextManager fetch:fetchRequest];
}

+ (NSArray*)loadFilters {
    DataContextManager* contextManager = [DataContextManager instance];

    NSString* filtersFile = [[NSBundle  mainBundle] pathForResource:@"Filters" ofType:@"plist"];
    NSArray* configuredFilters = [[NSDictionary dictionaryWithContentsOfFile:filtersFile] objectForKey:@"filters"];
    NSInteger configuredFilterCount = [configuredFilters count];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* filterEntity = [NSEntityDescription entityForName:@"Filter" inManagedObjectContext:contextManager.mainObjectContext];
    [fetchRequest setEntity:filterEntity];   
    NSInteger filterCount = [contextManager count:fetchRequest];

    if (filterCount < configuredFilterCount) {
        for (int i = 0; i < (configuredFilterCount - filterCount); i++) {
            Filter* filter = (Filter*)[NSEntityDescription insertNewObjectForEntityForName:@"Filter" inManagedObjectContext:contextManager.mainObjectContext];
            NSDictionary* configuredFilter  = [configuredFilters objectAtIndex:(filterCount + i)];
            filter.name                = [configuredFilter objectForKey:@"name"];
            filter.filterId            = [configuredFilter objectForKey:@"filterId"];
            filter.imageFilename       = [configuredFilter objectForKey:@"imageFilename"];
            filter.purchased           = [configuredFilter objectForKey:@"purchased"];
            filter.hidden              = [configuredFilter objectForKey:@"hidden"];
            filter.defaultValue        = [configuredFilter objectForKey:@"defaultValue"];
            filter.minimumValue        = [configuredFilter objectForKey:@"minimumValue"];
            filter.maximumValue        = [configuredFilter objectForKey:@"maximumValue"];
            filter.filterPalette       = [self filterPalette:[configuredFilter objectForKey:@"filterPaletteId"]];
            filter.usageRate           = [NSNumber numberWithFloat:0.0];
            filter.usageCount          = [NSNumber numberWithFloat:0.0];
            [contextManager save];
        }
    }

    return [contextManager fetch:fetchRequest];
}

+ (UIImage*)outputImageForFilter:(GPUImageOutput<GPUImageInput>*)_filter andImage:(UIImage*)_image {
    GPUImagePicture* filteredImage = [[GPUImagePicture alloc] initWithImage:_image];
    [filteredImage addTarget:_filter];
    [filteredImage processImage];
    return [_filter imageFromCurrentlyProcessedOutputWithOrientation:_image.imageOrientation];
}

#pragma mark - 
#pragma mark FilterFactory

+ (FilterFactory*)instance {	
    @synchronized(self) {
        if (thisFilterFactory == nil) {
            thisFilterFactory = [[self alloc] init];
            thisFilterFactory.loadedFilterPalettes= [self loadFilterPalettes];
            thisFilterFactory.loadedFilters = [self loadFilters];
        }
    }
    return thisFilterFactory;
}

- (FilterPalette*)defaultFilterPalette {
    return [self.loadedFilterPalettes objectAtIndex:FilterPaletteTypeColorAjustmentControls];
}

- (Filter*)defaultFilterForPalette:(FilterPalette*)_filterPalette {
    DataContextManager* contextManager = [DataContextManager instance];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* filterPaletteEntity = [NSEntityDescription entityForName:@"Filter" inManagedObjectContext:contextManager.mainObjectContext];
    [fetchRequest setEntity:filterPaletteEntity];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"usageRate" ascending:NO]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"filterPalette.filterPaletteId=%@", _filterPalette.filterPaletteId]];
    [fetchRequest setFetchLimit:1];
    return [[contextManager fetch:fetchRequest] objectAtIndex:0];
}

- (NSArray*)filterPalettes {
    return self.loadedFilterPalettes;
}

- (NSArray*)filtersForPalette:(FilterPalette*)_filterPalette {
    return [self.loadedFilters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"filterPalette.filterPaletteId == %@", _filterPalette.filterPaletteId]];    
}

+ (UIImage*)applyFilter:(Filter*)_filter withValue:(NSNumber*)_value toImage:(UIImage*)_image {
    UIImage* outputImage = nil;
    switch ([_filter.filterId intValue]) {
        case FilterTypeBrightness:
            outputImage = [self applyBrightnessFilterWithValue:_value toImage:_image];
            break;
        case FilterTypeRedColor:
            outputImage = [self applyRedColorFilterWithValue:_value toImage:_image];
            break;
        case FilterTypeGreenColor:
            outputImage = [self applyGreenColorFilterWithValue:_value toImage:_image];
            break;
        case FilterTypeBlueColor:
            outputImage = [self applyBlueColorFilterWithValue:_value toImage:_image];
            break;
        case FilterTypeSaturation:
            outputImage = [self applySaturationFilterWithValue:_value toImage:_image];
            break;
        case FilterTypeContrast:
            outputImage = [self applyContrastFilterWithValue:_value toImage:_image];
            break;
        case FilterTypeVignette:
            outputImage = [self applyVignetteFilterWithValue:_value toImage:_image];
            break;
        case FilterTypeInstant:
            outputImage = [self applyInstantFilterWithValue:_value toImage:_image];
            break;
        case FilterTypePixel:
            outputImage = [self applyPixelFilterWithValue:_value toImage:_image];
            break;
        case FilterTypeBox:
            outputImage = [self applyBoxFilterWithValue:_value toImage:_image];
            break;
        case FilterTypePlastic:
            outputImage = [self applyPlasticFilterWithValue:_value toImage:_image];
            break;
        default:
            break;
    }
    return outputImage;
}


#pragma mark - 
#pragma mark FilterFacory Filters

+ (UIImage*)applyBrightnessFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    GPUImageBrightnessFilter* filter = [[GPUImageBrightnessFilter alloc] init];
    [filter setBrightness:[_value floatValue]];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyContrastFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    GPUImageContrastFilter* filter = [[GPUImageContrastFilter alloc] init];
    [filter setContrast:[_value floatValue]];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applySaturationFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    GPUImageSaturationFilter* filter = [[GPUImageSaturationFilter alloc] init];
    [filter setSaturation:[_value floatValue]];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyVignetteFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    GPUImageVignetteFilter* filter = [[GPUImageVignetteFilter alloc] init];
    [filter setVignetteEnd:[_value floatValue]];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyRedColorFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    GPUImageRGBFilter* filter = [[GPUImageRGBFilter alloc] init];
    [filter setRed:[_value floatValue]];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyGreenColorFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    GPUImageRGBFilter* filter = [[GPUImageRGBFilter alloc] init];
    [filter setGreen:[_value floatValue]];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyBlueColorFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    GPUImageRGBFilter* filter = [[GPUImageRGBFilter alloc] init];
    [filter setBlue:[_value floatValue]];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyInstantFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    CameraFactory* cameraFactory = [CameraFactory instance];
    GPUImageOutput<GPUImageInput>* filter = [cameraFactory filterInstantCamera];
    [cameraFactory setInstantCameraParameterValue:_value forFilter:filter];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyPixelFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    CameraFactory* cameraFactory = [CameraFactory instance];
    GPUImageOutput<GPUImageInput>* filter = [cameraFactory filterPixelCamera];
    [cameraFactory setPixelCameraParameterValue:_value forFilter:filter];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyBoxFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    CameraFactory* cameraFactory = [CameraFactory instance];
    GPUImageOutput<GPUImageInput>* filter = [cameraFactory filterBoxCamera];
    [cameraFactory setBoxCameraParameterValue:_value forFilter:filter];
    return [self outputImageForFilter:filter andImage:_image];
}

+ (UIImage*)applyPlasticFilterWithValue:(NSNumber*)_value toImage:(UIImage*)_image {
    CameraFactory* cameraFactory = [CameraFactory instance];
    GPUImageOutput<GPUImageInput>* filter = [cameraFactory filterPlasticCamera];
    [cameraFactory setPlasticCameraParameterValue:_value forFilter:filter];
    return [self outputImageForFilter:filter andImage:_image];
}

@end
