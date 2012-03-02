//
//  PXAnchoredMenuButtonCell.m
//  Schoolhouse
//
//  Created by Logan Collins on 2/24/10.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXAnchoredMenuButtonCell.h"


@implementation PXAnchoredMenuButtonCell

- (NSPoint)menuPositionForFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSPoint result = [controlView convertPoint:cellFrame.origin toView:nil];
	result.y -= cellFrame.size.height + 4.5;
	return result;
}

- (void)showMenuForEvent:(NSEvent *)theEvent controlView:(NSView *)controlView cellFrame:(NSRect)cellFrame {
	NSPoint menuPosition = [self menuPositionForFrame:cellFrame inView:controlView];
	
	// Create event for pop up menu with adjusted mouse position
	NSEvent *menuEvent = [NSEvent mouseEventWithType:[theEvent type]
											location:menuPosition
									   modifierFlags:[theEvent modifierFlags]
										   timestamp:[theEvent timestamp]
										windowNumber:[theEvent windowNumber]
											 context:[theEvent context]
										 eventNumber:[theEvent eventNumber]
										  clickCount:[theEvent clickCount]
											pressure:[theEvent pressure]];
	
	[NSMenu popUpContextMenu:([self menu] ? [self menu] : [controlView menu]) withEvent:menuEvent forView:controlView];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
	BOOL result = NO;
	NSDate *endDate;
	NSPoint currentPoint = [theEvent locationInWindow];
	BOOL done = NO;
	BOOL trackContinously = [self startTrackingAt:currentPoint inView:controlView];
	
	// Catch next mouse-dragged or mouse-up event until timeout
	BOOL mouseIsUp = NO;
	NSEvent *event;
	while (!done) {
		NSPoint lastPoint = currentPoint;
		
		// Set up timer for pop-up menu if we have one
		if ([self menu] || [controlView menu])
			endDate = [NSDate dateWithTimeIntervalSinceNow:0.6];
		else
			endDate = [NSDate distantFuture];
		
		event = [NSApp nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)
								   untilDate:endDate
									  inMode:NSEventTrackingRunLoopMode
									 dequeue:YES];
		
		if (event) { // Mouse event
			currentPoint = [event locationInWindow];
			
			// Send continueTracking.../stopTracking...
			if (trackContinously) {
				if (![self continueTracking:lastPoint at:currentPoint inView:controlView]) {
					done = YES;
					[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:mouseIsUp];
				}
				
				if ([self isContinuous]) {
					[NSApp sendAction:[self action] to:[self target] from:controlView];
				}
			}
			
			mouseIsUp = ([event type] == NSLeftMouseUp);
			done = done || mouseIsUp;
			
			if (untilMouseUp) {
				result = mouseIsUp;
			}
			else {
				// Check if the mouse left our cell rect
				result = NSPointInRect([controlView convertPoint:currentPoint fromView:nil], cellFrame);
				if (!result)
					done = YES;
			}
			
			if (done && result && ![self isContinuous])
				[NSApp sendAction:[self action] to:[self target] from:controlView];
			
		}
		else { // Show menu
			done = YES;
			result = YES;
			[self showMenuForEvent:theEvent controlView:controlView cellFrame:cellFrame];
		}
	}
	return result;
}

@end
