//
//  PXControl.m
//  Photon
//
//  Created by Logan Collins on 9/2/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "PXControl.h"


@interface PXControl ()

@property (nonatomic, readwrite) PXControlState state;
@property (nonatomic, readwrite, getter=isTracking) BOOL tracking;
@property (nonatomic, readwrite, getter=isTrackingInside) BOOL trackingInside;

@end


@implementation PXControl {
    NSMapTable *_actionsByTarget;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _actionsByTarget = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}


#pragma mark -
#pragma mark Accessors

- (BOOL)isEnabled {
    return !(self.state & PXControlStateDisabled);
}

- (void)setEnabled:(BOOL)enabled {
    if (enabled) {
        self.state = self.state & ~(PXControlStateDisabled);
    }
    else {
        self.state |= PXControlStateDisabled;
    }
}

- (BOOL)isSelected {
    return self.state & PXControlStateSelected;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.state |= PXControlStateSelected;
    }
    else {
        self.state = self.state & ~(PXControlStateHighlighted);
    }
}

- (BOOL)isHighlighted {
    return self.state & PXControlStateHighlighted;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.state |= PXControlStateHighlighted;
    }
    else {
        self.state = self.state & ~(PXControlStateHighlighted);
    }
}


#pragma mark -
#pragma mark Actions

- (NSSet *)allTargets {
    return [NSSet setWithArray:[[_actionsByTarget keyEnumerator] allObjects]];
}

- (PXControlEvents)allControlEvents {
    PXControlEvents events = 0;
    for (id target in _actionsByTarget) {
        NSDictionary *targetInfo = [_actionsByTarget objectForKey:target];
        
    }
    return events;
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(PXControlEvents)controlEvent {
    NSDictionary *targetInfo = [_actionsByTarget objectForKey:target];
    NSDictionary *events = targetInfo[@"events"];
    NSArray *actions = events[@(controlEvent)];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(NSEvent *)event {
    
}

- (void)sendActionsForControlEvents:(PXControlEvents)controlEvents {
    
}


#pragma mark -
#pragma mark Event Tracking

- (BOOL)beginTrackingWithEvent:(NSEvent *)event {
    return YES;
}

- (BOOL)continueTrackingWithEvent:(NSEvent *)event {
    return YES;
}

- (void)endTrackingWithEvent:(NSEvent *)event {
    
}

- (void)cancelTrackingWithEvent:(NSEvent *)event {
    
}


#pragma mark -
#pragma mark Responder

- (void)mouseDown:(NSEvent *)theEvent {
    BOOL shouldContinue = [self beginTrackingWithEvent:theEvent];
    if (shouldContinue) {
        self.tracking = YES;
        self.trackingInside = YES;
    }
    
    [self sendActionsForControlEvents:(PXControlEventMouseDown)];
    if ([theEvent clickCount] > 1) {
        [self sendActionsForControlEvents:(PXControlEventMouseDownRepeat)];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (self.tracking) {
        if (self.trackingInside) {
            [self sendActionsForControlEvents:(PXControlEventMouseUpInside)];
        }
        else {
            [self sendActionsForControlEvents:(PXControlEventMouseUpOutside)];
        }
        
        [self endTrackingWithEvent:theEvent];
        
        self.tracking = NO;
        self.trackingInside = NO;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (self.tracking) {
        BOOL shouldContinue = [self continueTrackingWithEvent:theEvent];
        if (shouldContinue) {
            if (self.trackingInside) {
                [self sendActionsForControlEvents:(PXControlEventMouseDragInside)];
            }
            else {
                [self sendActionsForControlEvents:(PXControlEventMouseDragOutside)];
            }
        }
        else {
            self.tracking = NO;
            self.trackingInside = NO;
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if (self.tracking) {
        [self sendActionsForControlEvents:(PXControlEventMouseDragEnter)];
        self.trackingInside = YES;
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    if (self.tracking) {
        [self sendActionsForControlEvents:(PXControlEventMouseDragExit)];
        self.trackingInside = NO;
    }
}

@end
