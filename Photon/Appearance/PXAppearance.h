
//
//  PXAppearance.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PhotonDefines.h>


/*!
 * @constant PX_APPEARANCE_SELECTOR
 * @abstract Marks a method that participates in the appearance customization API
 */
#define PX_APPEARANCE_SELECTOR


/*!
 * @protocol PXAppearanceContainer <NSObject>
 * @abstract Implemented by objects adopting the appearance customization container API
 */
@protocol PXAppearanceContainer <NSObject> @end


/*!
 * @protocol PXAppearance
 * @abstract Implemented by objects participating in the appearance customization API
 */
@protocol PXAppearance <NSObject>

/*!
 * @method px_appearance
 * @abstract Returns the appearance proxy for the receiver
 * 
 * @result An object
 */
+ (id)px_appearance;

/*!
 * @method px_appearanceWhenContainedIn:
 * @abstract Returns the appearance proxy for the receiver in a given containment hierarchy
 * 
 * @discussion
 * This method throws an exception for any item in the var-args list that is not a Class object that conforms to the PXApperanceContainer protocol.
 * 
 * @result An object
 */
+ (id)px_appearanceWhenContainedIn:(Class <PXAppearanceContainer>)containerClass, ... NS_REQUIRES_NIL_TERMINATION;

@end


/*!
 * @category NSView(PXAppearance)
 * @abstract Additions for NSView to support the appearance customization API
 */
@interface NSView (PXAppearance) <PXAppearance, PXAppearanceContainer> @end


/*!
 * @category NSViewController(PXAppearance)
 * @abstract Additions for NSViewController to support the appearance customization API
 */
@interface NSViewController (PXAppearance) <PXAppearanceContainer> @end


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
