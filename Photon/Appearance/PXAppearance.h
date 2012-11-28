
//
//  PXAppearance.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photon/PhotonDefines.h>


/*!
 * @enum PXAppearanceBorder
 * @abstract Bitmask values for borders
 * 
 * @constant PXAppearanceBorderNone      No borders
 * @constant PXAppearanceBorderTop       Top border
 * @constant PXAppearanceBorderBottom    Bottom border
 * @constant PXAppearanceBorderLeft      Left border
 * @constant PXAppearanceBorderRight     Right border
 * @constant PXAppearanceBorderAll       All borders
 */
typedef PHOTON_ENUM(NSUInteger, PXAppearanceBorder) {
    PXAppearanceBorderNone = 0,
    PXAppearanceBorderTop = (1 << 0),
    PXAppearanceBorderBottom = (1 << 1),
    PXAppearanceBorderLeft = (1 << 2),
    PXAppearanceBorderRight = (1 << 3),
    PXAppearanceBorderAll = (PXAppearanceBorderTop|PXAppearanceBorderBottom|PXAppearanceBorderLeft|PXAppearanceBorderRight),
};


/*!
 * @enum PXAppearanceState
 * @abstract Bitmask values for control state
 * 
 * @constant PXAppearanceStateNormal        The UI element is in its default state, enabled but not selected in any way
 * @constant PXAppearanceStateHighlighted   The UI element is highlighted (through a click, tap or tracking)
 * @constant PXAppearanceStateDisabled      The UI element is disabled
 * @constant PXAppearanceStateSelected      The UI element is selected (as in a selected segmented control segment)
 * @constant PXAppearanceStateHovered       The UI element is hovered (through a mouse hover or drag hover)
 */
typedef PHOTON_ENUM(NSUInteger, PXAppearanceState) {
    PXAppearanceStateNormal = 0,
    PXAppearanceStateHighlighted = (1 << 0),
    PXAppearanceStateDisabled = (1 << 1),
    PXAppearanceStateSelected = (1 << 2),
    PXAppearanceStateHovered = (1 << 3),
};


/*!
 * @constant PX_APPEARANCE_SELECTOR
 * @abstract Marks a method that participates in the appearance proxy API
 */
#define PX_APPEARANCE_SELECTOR


/*!
 * @protocol PXAppearanceContainer <NSObject>
 * @abstract Implemented by objects adopting the appearance customization API.
 */
@protocol PXAppearanceContainer <NSObject> @end


/*!
 * @protocol PXAppearance
 * @abstract Implemented by objects that can customize their appearance
 */
@protocol PXAppearance <NSObject>

+ (id)appearance;
+ (id)appearanceWhenContainedIn:(Class <PXAppearanceContainer>)containerClass, ... NS_REQUIRES_NIL_TERMINATION;

@end


@interface NSView (PXAppearance) <PXAppearance>

@end
