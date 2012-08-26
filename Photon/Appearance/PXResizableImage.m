//
//  PXResizableImage.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXResizableImage.h"


@interface PXResizableImage ()

#if TARGET_OS_IPHONE
- (id)initWithImage:(UIImage *)image capInsets:(PXEdgeInsets)capInsets;
#else
- (id)initWithImage:(NSImage *)image capInsets:(PXEdgeInsets)capInsets;
#endif

@property (readwrite) PXEdgeInsets capInsets;

@end


@implementation PXResizableImage

@synthesize capInsets=_capInsets;
@synthesize image=_image;

+ (PXResizableImage *)resizableImageNamed:(NSString *)imageName {
    return [self resizableImageNamed:imageName capInsets:PXEdgeInsetsZero];
}

+ (PXResizableImage *)resizableImageNamed:(NSString *)imageName capInsets:(PXEdgeInsets)capInsets {
#if TARGET_OS_IPHONE
    UIImage *image = [UIImage imageNamed:imageName];
    if (image != nil) {
        return [self resizableImageWithImage:image];
    }
    return nil;
#else
    NSImage *image = [NSImage imageNamed:imageName];
    if (image != nil) {
        return [self resizableImageWithImage:image];
    }
    return nil;
#endif
}

#if TARGET_OS_IPHONE

+ (PXResizableImage *)resizableImageWithImage:(UIImage *)image {
    return [self resizableImageWithImage:image capInsets:PXEdgeInsetsZero];
}

+ (PXResizableImage *)resizableImageWithImage:(UIImage *)image capInsets:(PXEdgeInsets)capInsets {
    image = [image resizableImageWithCapInsets:(UIEdgeInsets)capInsets];
    return [[[self alloc] initWithImage:image] autorelease];
}

- (id)initWithImage:(UIImage *)image capInsets:(PCEdgeInsets)capInsets {
    self = [super init];
    if (self) {
        _image = [image retain];
        _capInsets = capInsets;
    }
    return self;
}

#else

+ (PXResizableImage *)resizableImageWithImage:(NSImage *)image {
    return [self resizableImageWithImage:image capInsets:PXEdgeInsetsZero];
}

+ (PXResizableImage *)resizableImageWithImage:(NSImage *)image capInsets:(PXEdgeInsets)capInsets {
    return [[self alloc] initWithImage:image capInsets:capInsets];
}

- (id)initWithImage:(NSImage *)image capInsets:(PXEdgeInsets)capInsets {
    self = [super init];
    if (self) {
        _image = image;
        _capInsets = capInsets;
    }
    return self;
}

#endif

#if TARGET_OS_IPHONE

- (void)drawInRect:(CGRect)rect {
    [_image drawInRect:rect];
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [_image drawInRect:rect blendMode:blendMode alpha:alpha];
}

#else

- (void)drawInRect:(CGRect)rect {
    [self drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    CGImageRef topLeftImage, topImage, topRightImage, leftImage, fillImage, rightImage, bottomLeftImage, bottomImage, bottomRightImage;
    
    CGImageRef cgImage = [_image CGImageForProposedRect:&rect context:[NSGraphicsContext currentContext] hints:nil];
    NSSize imageSize = [_image size];
    
    topLeftImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(0.0, imageSize.height - _capInsets.top, _capInsets.left, _capInsets.top));
    topImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(_capInsets.left, imageSize.height - _capInsets.top, imageSize.width - (_capInsets.left + _capInsets.right), _capInsets.top));
    topRightImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(imageSize.width - _capInsets.right, imageSize.height - _capInsets.top, _capInsets.right, _capInsets.top));
    
    leftImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(0.0, _capInsets.top, _capInsets.left, imageSize.height - (_capInsets.top + _capInsets.bottom)));
    fillImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(_capInsets.left, _capInsets.top, imageSize.width - (_capInsets.left + _capInsets.right), imageSize.height - (_capInsets.top + _capInsets.bottom)));
    rightImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(imageSize.width - _capInsets.right, _capInsets.top, _capInsets.right, imageSize.height - (_capInsets.top + _capInsets.bottom)));
    
    bottomLeftImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(0.0, 0.0, _capInsets.left, _capInsets.bottom));
    bottomImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(_capInsets.left, 0.0, imageSize.width - (_capInsets.left + _capInsets.right), _capInsets.bottom));
    bottomRightImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(imageSize.width - _capInsets.right, 0.0, _capInsets.right, _capInsets.bottom));
    
    
    NSImage *composedImage = [[NSImage alloc] initWithSize:rect.size];
    [composedImage lockFocus];
    
    CGContextRef c = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSaveGState(c);
    
    CGContextSetBlendMode(c, blendMode);
    
    CGContextDrawImage(c, CGRectMake(0.0, rect.size.height - _capInsets.top, _capInsets.left, _capInsets.top), topLeftImage);
    CGContextDrawImage(c, CGRectMake(_capInsets.left, rect.size.height - _capInsets.top, rect.size.width - (_capInsets.left + _capInsets.right), _capInsets.top), topImage);
    CGContextDrawImage(c, CGRectMake(rect.size.width - _capInsets.right, rect.size.height - _capInsets.top, _capInsets.right, _capInsets.top), topRightImage);
    
    CGContextDrawImage(c, CGRectMake(0.0, _capInsets.top, _capInsets.left, rect.size.height - (_capInsets.top + _capInsets.bottom)), leftImage);
    CGContextDrawImage(c, CGRectMake(_capInsets.left, _capInsets.top, rect.size.width - (_capInsets.left + _capInsets.right), rect.size.height - (_capInsets.top + _capInsets.bottom)), fillImage);
    CGContextDrawImage(c, CGRectMake(rect.size.width - _capInsets.right, _capInsets.top, _capInsets.right, rect.size.height - (_capInsets.top + _capInsets.bottom)), rightImage);
    
    CGContextDrawImage(c, CGRectMake(0.0, 0.0, _capInsets.left, _capInsets.bottom), bottomLeftImage);
    CGContextDrawImage(c, CGRectMake(_capInsets.left, 0.0, rect.size.width - (_capInsets.left + _capInsets.right), _capInsets.bottom), bottomImage);
    CGContextDrawImage(c, CGRectMake(rect.size.width - _capInsets.right, 0.0, _capInsets.right, _capInsets.bottom), bottomRightImage);
    
    CGContextRestoreGState(c);
    
    [composedImage unlockFocus];
    
    
    if (topLeftImage != NULL) CFRelease(topLeftImage);
    if (topImage != NULL) CFRelease(topImage);
    if (topRightImage != NULL) CFRelease(topRightImage);
    if (leftImage != NULL) CFRelease(leftImage);
    if (fillImage != NULL) CFRelease(fillImage);
    if (rightImage != NULL) CFRelease(rightImage);
    if (bottomLeftImage != NULL) CFRelease(bottomLeftImage);
    if (bottomImage != NULL) CFRelease(bottomImage);
    if (bottomRightImage != NULL) CFRelease(bottomRightImage);
}

#endif

@end
