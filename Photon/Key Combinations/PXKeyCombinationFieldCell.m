//
//  PXKeyCombinationFieldCell.m
//  LCToolkit
//
//  Created by Logan Collins on 7/19/09.
//  Copyright 2009 Logan Collins. All rights reserved.
//

#import "PXKeyCombinationFieldCell.h"



@implementation PXKeyCombinationFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSRect whiteRect = cellFrame;
	NSBezierPath *roundedRect;
	
	// Draw gradient when in recording mode
	if (isRecording) {
		roundedRect = [NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:NSHeight(cellFrame)/2.0 yRadius:NSHeight(cellFrame)/2.0];
		
		// Fill background with gradient
		[[NSGraphicsContext currentContext] saveGraphicsState];
		[roundedRect addClip];
		[recordingGradient drawInRect:cellFrame angle:90.0];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
		
		// Highlight if inside or down
		if (mouseInsideTrackingArea) {
			[[[NSColor blackColor] colorWithAlphaComponent:(mouseDown ? 0.4 : 0.2)] set];
			[roundedRect fill];
		}
		
		// Draw snapback image
		NSImage *snapbackArrow = [NSImage imageNamed:@"PXKeyCombinationSnapback"];
		[snapbackArrow drawAtPoint:[self _snapbackRectForFrame: cellFrame].origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
		// Because of the gradient and snapback image, the white rounded rect will be smaller
		whiteRect = NSInsetRect(cellFrame, 9.5, 2.0);
		whiteRect.origin.x -= 7.5;
	}
	
	// Draw white rounded box
	roundedRect = [NSBezierPath bezierPathWithRoundedRect:whiteRect xRadius:NSHeight(whiteRect)/2.0 yRadius:NSHeight(whiteRect)/2.0];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[roundedRect addClip];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:whiteRect];
	
	// Draw border and remove badge if needed
	if (!isRecording) {
		[[NSGraphicsContext currentContext] saveGraphicsState];
		
		NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		[shadow setShadowBlurRadius:2.0];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.5]];
		[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
		[shadow set];
		
		[[NSColor colorWithCalibratedWhite:0.45 alpha:1.0] set];
		[roundedRect stroke];
		
		[[NSGraphicsContext currentContext] restoreGraphicsState];
		
		// If key combination is set and valid, draw remove image
		if ([self keyCombination] != nil && [self isEnabled]) {
			NSString *removeImageName = [NSString stringWithFormat:@"PXKeyCombinationRemove%@", (mouseInsideTrackingArea ? (mouseDown ? @"Pressed" : @"Rollover") : (mouseDown ? @"Rollover" : @""))];
			NSImage *removeImage = [NSImage imageNamed:removeImageName];
			NSPoint removeOrigin = [self _removeButtonRectForFrame:cellFrame].origin;
			[removeImage drawAtPoint:removeOrigin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		}
	}
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	// Draw text
	NSMutableParagraphStyle *para = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[para setLineBreakMode:NSLineBreakByTruncatingTail];
	[para setAlignment:NSCenterTextAlignment];
	
	// Only the key combination should be black and in a bigger font size
	BOOL recordingOrEmpty = (isRecording || [self keyCombination] == nil);
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								para, NSParagraphStyleAttributeName,
								[NSFont systemFontOfSize:(recordingOrEmpty ? [NSFont labelFontSize] : [NSFont smallSystemFontSize])], NSFontAttributeName,
								(recordingOrEmpty ? [NSColor disabledControlTextColor] : [NSColor blackColor]), NSForegroundColorAttributeName,
								nil];
	
	NSString *displayString;
	
	if (isRecording) {
		// Recording, but no modifier keys down
		if (![self _validModifierFlags:_recordingFlagsMask]) {
			if (mouseInsideTrackingArea) {
                // Mouse over snapback
				displayString = NSLocalizedStringFromTable(@"Use old shortcut", @"KeyCombinations", nil);
			}
			else {
                // Mouse elsewhere
				displayString = NSLocalizedStringFromTable(@"Type shortcut", @"KeyCombinations", nil);
			}
		}
		else {
			// Display currently pressed modifier keys
			displayString = LCStringForCocoaModifierFlags(_recordingFlagsMask);
			
			// Fall back on 'Type shortcut' if we don't have modifier flags to display; this will happen for the fn key depressed
			if (![displayString length]) {
				displayString = NSLocalizedStringFromTable(@"Type shortcut", @"KeyCombinations", nil);
			}
		}
	}
	else {
		// Not recording...
		if ([self keyCombination] == nil) {
			displayString = NSLocalizedStringFromTable(@"Click to record shortcut", @"KeyCombinations", nil);
		}
		else {
			// Display current key combination
			displayString = [keyCombination keyCodeAndModifiersString];
		}
	}
	
	// Calculate rect in which to draw the text in...
	NSRect textRect = cellFrame;
	textRect.size.width -= 6;
	textRect.size.width -= ((!isRecording && [self keyCombination] == nil) ? 6 : (isRecording ? [self _snapbackRectForFrame: cellFrame].size.width : [self _removeButtonRectForFrame: cellFrame].size.width) + 6);
	textRect.origin.x += 6;
	textRect.origin.y = -(NSMidY(cellFrame) - [displayString sizeWithAttributes: attributes].height/2);
	
	// Finally draw it
	[displayString drawInRect:textRect withAttributes:attributes];
	
	// Draw a focus ring...?
	/*if ([self showsFirstResponder]) {
     [NSGraphicsContext saveGraphicsState];
     NSSetFocusRingStyle(NSFocusRingOnly);
     [[NSBezierPath bezierPathWithRoundedRect:cellFrame xRadius:NSHeight(whiteRect)/2.0 yRadius:NSHeight(whiteRect)/2.0] fill];
     [NSGraphicsContext restoreGraphicsState];
     }*/
}


#pragma mark -
#pragma mark Mouse Tracking

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSControl *)controlView untilMouseUp:(BOOL)flag {
	NSEvent *currentEvent = theEvent;
	NSPoint mouseLocation;
	
	NSRect trackingRect = (isRecording ? [self _snapbackRectForFrame: cellFrame] : [self _removeButtonRectForFrame: cellFrame]);
	NSRect leftRect = cellFrame;
    
	// Determine the area without any badge
	if (!NSEqualRects(trackingRect,NSZeroRect)) leftRect.size.width -= NSWidth(trackingRect) + 4;
    
	do {
        mouseLocation = [controlView convertPoint: [currentEvent locationInWindow] fromView:nil];
		
		switch ([currentEvent type]) {
			case NSLeftMouseDown:
			{
				// Check if mouse is over remove/snapback image
				if ([controlView mouse:mouseLocation inRect:trackingRect]) {
					mouseDown = YES;
					[controlView setNeedsDisplayInRect: cellFrame];
				}
				
				break;
			}
			case NSLeftMouseDragged:
			{
				// Recheck if mouse is still over the image while dragging
				mouseInsideTrackingArea = [controlView mouse:mouseLocation inRect:trackingRect];
				[controlView setNeedsDisplayInRect: cellFrame];
				
				break;
			}
			default: // NSLeftMouseUp
			{
				mouseDown = NO;
				mouseInsideTrackingArea = [controlView mouse:mouseLocation inRect:trackingRect];
                
				if (mouseInsideTrackingArea) {
					if (isRecording) {
						// Mouse was over snapback, just redraw
                        [self _endRecording];
					}
					else
					{
						// Mouse was over the remove image, reset all
						[self setKeyCombination:nil];
					}
				}
				else if ([controlView mouse:mouseLocation inRect:leftRect] && !isRecording)
				{
					if ([self isEnabled]) {
                        [self startRecording];
					}
					/* maybe beep if not editable?
					 else
                     {
                     NSBeep();
                     }
					 */
				}
				
				// Any click inside will make us firstResponder
				if ([self isEnabled]) [[controlView window] makeFirstResponder:controlView];
				
				// Reset tracking rects and redisplay
				[self updateTrackingAreas];
				[controlView setNeedsDisplayInRect: cellFrame];
				
				return YES;
			}
		}
		
    } while ((currentEvent = [[controlView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask) untilDate:[NSDate distantFuture] inMode:NSEventTrackingRunLoopMode dequeue:YES]));
	
    return YES;
}

@end
