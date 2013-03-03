// UIImage+Resize.h
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Extends the UIImage class to support resizing/cropping
@interface UIImage (Resize)

- (UIImage*)scaleBy:(CGFloat)_scaleBy andCropToSize:(CGSize)_size;
- (UIImage*)croppedImage:(CGRect)bounds;
- (UIImage*)thumbnailImage:(NSInteger)thumbnailSize;
- (UIImage*)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)resizedImageWithContentMode:(UIViewContentMode)contentMode bounds:(CGSize)bounds interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)scaleToSize:(CGSize)_frame;
- (UIImage*)transformPhotoImage;

@end
