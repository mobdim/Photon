//
//  PXAppearance.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photon/PhotonDefines.h>


#if TARGET_OS_IPHONE

#import <UIKit/UIGeometry.h>

typedef UIEdgeInsets PXEdgeInsets;

#else

typedef struct PXEdgeInsets {
    CGFloat top, left, bottom, right;
} PXEdgeInsets;

#endif


PHOTON_INLINE PXEdgeInsets PXEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
#if TARGET_OS_IPHONE
    return UIEdgeInsetsMake(top, left, bottom, right);
#else
    PXEdgeInsets insets = {top, left, bottom, right};
    return insets;
#endif
}


PHOTON_INLINE BOOL PXEdgeInsetsEqualToEdgeInsets(PXEdgeInsets insets1, PXEdgeInsets insets2) {
#if TARGET_OS_IPHONE
    return UIEdgeInsetsEqualToEdgeInsets((UIEdgeInsets)insets1, (UIEdgeInsets)insets2);
#else
    return (insets1.top == insets2.top) && (insets1.left == insets2.left) && (insets1.bottom == insets2.bottom) && (insets1.right == insets2.right);
#endif
}


PHOTON_EXTERN const PXEdgeInsets PXEdgeInsetsZero;
