//
//  PXAppearance.h
//  Photon
//
//  Created by Logan Collins on 3/23/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photon/PhotonDefines.h>


#if TARGET_OS_IPHONE

#import <UIKit/UIGeometry.h>

typedef UIEdgeInsets PXEdgeInsets;

#elif TARGET_OS_MAC

typedef struct PXEdgeInsets {
    CGFloat top, left, bottom, right;
} PXEdgeInsets;

#endif


PHOTON_STATIC_INLINE PXEdgeInsets PXEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
#if TARGET_OS_IPHONE
    return UIEdgeInsetsMake(top, left, bottom, right);
#elif TARGET_OS_MAC
    PXEdgeInsets insets = {top, left, bottom, right};
    return insets;
#endif
}


PHOTON_STATIC_INLINE BOOL PXEdgeInsetsEqualToEdgeInsets(PXEdgeInsets insets1, PXEdgeInsets insets2) {
#if TARGET_OS_IPHONE
    return UIEdgeInsetsEqualToEdgeInsets((UIEdgeInsets)insets1, (UIEdgeInsets)insets2);
#elif TARGET_OS_MAC
    return (insets1.top == insets2.top) && (insets1.left == insets2.left) && (insets1.bottom == insets2.bottom) && (insets1.right == insets2.right);
#endif
}


PHOTON_EXTERN const PXEdgeInsets PXEdgeInsetsZero;
