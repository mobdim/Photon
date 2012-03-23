//
//  PXAppearance.h
//  Photon
//
//  Created by Logan Collins on 3/23/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PXResizableImage;


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
enum {
    PXAppearanceBorderNone = 0,
    
    PXAppearanceBorderTop = (1 << 0),
    PXAppearanceBorderBottom = (1 << 1),
    PXAppearanceBorderLeft = (1 << 2),
    PXAppearanceBorderRight = (1 << 3),
    
    PXAppearanceBorderAll = (PXAppearanceBorderTop|PXAppearanceBorderBottom|PXAppearanceBorderLeft|PXAppearanceBorderRight),
};
typedef NSUInteger PXAppearanceBorder;


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
enum {
    PXAppearanceStateNormal = 0,
    
    PXAppearanceStateHighlighted = (1 << 0),
    PXAppearanceStateDisabled = (1 << 1),
    PXAppearanceStateSelected = (1 << 2),
    PXAppearanceStateHovered = (1 << 3),
};
typedef NSUInteger PXAppearanceState;


/*!
 * @protocol PXAppearanceFactory
 * @abstract Implemented by objects able to generate appearance resources
 */
@protocol PXAppearanceFactory <NSObject>

/*!
 * @method backgroundImageWithSize:border:state:
 * @abstract Creates a background image
 * 
 * @param size
 * The size of the image
 * 
 * @param borders
 * The borders for the image
 * 
 * @param state
 * The state of the image
 * 
 * @result An NSImage object
 */
+ (NSImage *)backgroundImageWithSize:(NSSize)size border:(PXAppearanceBorder)border state:(PXAppearanceState)state;

/*!
 * @method resizableBackgroundImageWithBorder:state:
 * @abstract Creates a resizable background image
 * 
 * @param borders
 * The borders for the image
 * 
 * @param state
 * The state of the image
 * 
 * @result A PXResizableImage object
 */
+ (PXResizableImage *)resizableBackgroundImageWithBorder:(PXAppearanceBorder)border state:(PXAppearanceState)state;

@end
