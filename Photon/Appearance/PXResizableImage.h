//
//  PXResizableImage.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photon/PXGeometry.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif


@interface PXResizableImage : NSObject {
#if TARGET_OS_IPHONE
    UIImage *_image;
#elif TARGET_OS_MAC
    NSImage *_image;
#endif
    PXEdgeInsets _capInsets;
}

+ (PXResizableImage *)resizableImageNamed:(NSString *)imageName;
+ (PXResizableImage *)resizableImageNamed:(NSString *)imageName capInsets:(PXEdgeInsets)capInsets;


#if TARGET_OS_IPHONE

+ (PXResizableImage *)resizableImageWithImage:(UIImage *)image;
+ (PXResizableImage *)resizableImageWithImage:(UIImage *)image capInsets:(PXEdgeInsets)capInsets;

@property (retain, readonly) UIImage *image;

#elif TARGET_OS_MAC

+ (PXResizableImage *)resizableImageWithImage:(NSImage *)image;
+ (PXResizableImage *)resizableImageWithImage:(NSImage *)image capInsets:(PXEdgeInsets)capInsets;

@property (retain, readonly) NSImage *image;

#endif


@property (readonly) PXEdgeInsets capInsets;


- (void)drawInRect:(CGRect)rect;
- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

@end
