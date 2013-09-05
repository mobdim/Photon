//
//  PXControl.h
//  Photon
//
//  Created by Logan Collins on 9/2/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import <Photon/PXView.h>


typedef NS_OPTIONS(NSUInteger, PXControlEvents) {
    PXControlEventMouseDown           = 1 <<  0,      // on all downs
    PXControlEventMouseDownRepeat     = 1 <<  1,      // on multiple downs (click count > 1)
    PXControlEventMouseDragInside     = 1 <<  2,
    PXControlEventMouseDragOutside    = 1 <<  3,
    PXControlEventMouseDragEnter      = 1 <<  4,
    PXControlEventMouseDragExit       = 1 <<  5,
    PXControlEventMouseUpInside       = 1 <<  6,
    PXControlEventMouseUpOutside      = 1 <<  7,
    PXControlEventMouseCancel         = 1 <<  8,
    
    PXControlEventValueChanged        = 1 << 12,     // sliders, etc.
    
    PXControlEventEditingDidBegin     = 1 << 16,     // text fields
    PXControlEventEditingChanged      = 1 << 17,
    PXControlEventEditingDidEnd       = 1 << 18,
    PXControlEventEditingDidEndOnExit = 1 << 19,     // 'return key' ending editing
    
    PXControlEventAllMouseEvents      = 0x00000FFF,  // for mouse events
    PXControlEventAllEditingEvents    = 0x000F0000,  // for text fields
    PXControlEventApplicationReserved = 0x0F000000,  // range available for application use
    PXControlEventSystemReserved      = 0xF0000000,  // range reserved for internal framework use
    PXControlEventAllEvents           = 0xFFFFFFFF
};

typedef NS_ENUM(NSInteger, PXControlContentVerticalAlignment) {
    PXControlContentVerticalAlignmentCenter  = 0,
    PXControlContentVerticalAlignmentTop     = 1,
    PXControlContentVerticalAlignmentBottom  = 2,
    PXControlContentVerticalAlignmentFill    = 3,
};

typedef NS_ENUM(NSInteger, PXControlContentHorizontalAlignment) {
    PXControlContentHorizontalAlignmentCenter = 0,
    PXControlContentHorizontalAlignmentLeft   = 1,
    PXControlContentHorizontalAlignmentRight  = 2,
    PXControlContentHorizontalAlignmentFill   = 3,
};

typedef NS_OPTIONS(NSUInteger, PXControlState) {
    PXControlStateNormal       = 0,
    PXControlStateHighlighted  = 1 << 0,
    PXControlStateDisabled     = 1 << 1,
    PXControlStateSelected     = 1 << 2,                  // flag usable by app (see below)
    PXControlStateApplication  = 0x00FF0000,              // additional flags available for application use
    PXControlStateReserved     = 0xFF000000               // flags reserved for internal framework use
};


@interface PXControl : PXView

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@property (nonatomic) PXControlContentVerticalAlignment contentVerticalAlignment;
@property (nonatomic) PXControlContentHorizontalAlignment contentHorizontalAlignment;

@property (nonatomic, readonly) PXControlState state;
@property (nonatomic, readonly, getter=isTracking) BOOL tracking;
@property (nonatomic, readonly, getter=isTrackingInside) BOOL trackingInside;

- (BOOL)beginTrackingWithEvent:(NSEvent *)event;
- (BOOL)continueTrackingWithEvent:(NSEvent *)event;
- (void)endTrackingWithEvent:(NSEvent *)event;
- (void)cancelTrackingWithEvent:(NSEvent *)event;

// Add target/action for particular event. You can call this multiple times and you can specify multiple target/actions for a particular event.
// Passing in nil as the target goes up the responder chain. The action may optionally include the sender and the event in that order
// The action cannot be NULL. Note that the target is not retained.
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(PXControlEvents)controlEvents;

// Remove the target/action for a set of events. Pass in NULL for the action to remove all actions for that target
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(PXControlEvents)controlEvents;

// Get info about target & actions. This makes it possible to enumerate all target/actions by checking for each event kind
- (NSSet *)allTargets;                                                                     // Set may include NSNull to indicate at least one nil target
- (PXControlEvents)allControlEvents;                                                       // List of all events that have at least one action
- (NSArray *)actionsForTarget:(id)target forControlEvent:(PXControlEvents)controlEvent;    // Single event. Returns NSArray of NSString selector names. Returns nil if none

// Send the action. The first method is called for the event and is a point at which you can observe or override behavior. It is called repeately by the second.
- (void)sendAction:(SEL)action to:(id)target forEvent:(NSEvent *)event;
- (void)sendActionsForControlEvents:(PXControlEvents)controlEvents;                        // Send all actions associated with events

@end
