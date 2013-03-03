// UIImage+Resize.m
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"

// Private helper methods
@interface UIImage ()
- (UIImage *)resizedImage:(CGSize)newSize transform:(CGAffineTransform)transform drawTransposed:(BOOL)transpose interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
- (UIImage*)applyTransformToPhotoImage;
- (BOOL)drawTransposedForOrientation:(UIImageOrientation)_imageOrientation;
@end

@implementation UIImage (Resize)

- (UIImage*)scaleBy:(CGFloat)_scaleBy andCropToSize:(CGSize)_size {
    UIImage* resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(_scaleBy*self.size.width, _scaleBy*self.size.height) interpolationQuality:kCGInterpolationHigh];
    return [resizedImage croppedImage:CGRectMake((resizedImage.size.width - _size.width)/2, (resizedImage.size.height - _size.height)/2, _size.width, _size.height)];
}

// Returns a copy of this image that is cropped to the given bounds.
// The bounds will be adjusted using CGRectIntegral.
// This method ignores the image's imageOrientation setting.
- (UIImage *)croppedImage:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

// Returns a copy of this image that is squared to the thumbnail size.
// If transparentBorder is non-zero, a transparent border of the given size will be added around the edges of the thumbnail. (Adding a transparent border of at least one pixel in size has the side-effect of antialiasing the edges of the image when rotating it using Core Animation.)
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize {

    UIImage *resizedImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(thumbnailSize, thumbnailSize) interpolationQuality:kCGInterpolationHigh];
    
    // Crop out any part of the image that's larger than the thumbnail size
    // The cropped rect must be centered on the resized image
    // Round the origin points so that the size isn't altered when CGRectIntegral is later invoked
    CGRect cropRect = CGRectMake(round((resizedImage.size.width - thumbnailSize) / 2), round((resizedImage.size.height - thumbnailSize) / 2), thumbnailSize, thumbnailSize);
    return [resizedImage croppedImage:cropRect];
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
    BOOL drawTransposed;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    return [self resizedImage:newSize transform:[self transformForOrientation:newSize] drawTransposed:drawTransposed interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality {
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}

// Returns image scaled to screen size
- (UIImage*)scaleToSize:(CGSize)_cropSize {
    CGFloat imageScaleFactor = _cropSize.height / self.size.height;
    CGFloat imageScale = 1.0;
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            imageScale = 2.0;
        }
    }
    UIImage* scaledImage = [self scaleBy:imageScale*imageScaleFactor andCropToSize:CGSizeMake(imageScale*_cropSize.width, imageScale*_cropSize.height)];
    return [self.class imageWithCGImage:[scaledImage CGImage] scale:imageScale orientation:scaledImage.imageOrientation];;
}

- (UIImage*)transformPhotoImage {
    UIImage* newImage = nil;
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
            newImage = self;
            break;
        case UIImageOrientationUp:
            newImage = self;
            break;
        case UIImageOrientationRight:
            newImage = [self applyTransformToPhotoImage];
            break;
        case UIImageOrientationLeft:
            newImage = [self applyTransformToPhotoImage];
            break;            
        default:
            break;
    }
    return newImage;
}


#pragma mark -
#pragma mark Private helper methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize transform:(CGAffineTransform)transform drawTransposed:(BOOL)transpose interpolationQuality:(CGInterpolationQuality)quality {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    
    UIGraphicsBeginImageContext(newRect.size);
    CGImageRef imageRef = self.CGImage;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(ctx, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(ctx, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(ctx, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0.0, newSize.height);
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;

        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        default:
            break;
   }
    
    return transform;
}

- (UIImage*)applyTransformToPhotoImage {
    UIImage* newImage = nil;
    CGRect origRect = CGRectMake(0, 0, self.size.width, self.size.width);
    CGRect transposedRect = CGRectMake(0, 0, self.size.height, self.size.width);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0.0, self.size.height);
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
            break;
        case UIImageOrientationUp:
            break;
        case UIImageOrientationRight:
            transform = CGAffineTransformTranslate(transform, 0.0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationLeft:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;            
        default:
            break;
    }
    UIGraphicsBeginImageContext(self.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGImageRef imageRef = self.CGImage;
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, [self drawTransposedForOrientation:self.imageOrientation] ? transposedRect : origRect, imageRef);
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL)drawTransposedForOrientation:(UIImageOrientation)_imageOrientation {
    BOOL drawTransposed;
    switch (_imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            drawTransposed = YES;
            break;            
        default:
            drawTransposed = NO;
    }
    return drawTransposed;
}


#pragma clang diagnostic pop

@end
