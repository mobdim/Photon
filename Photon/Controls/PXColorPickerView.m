//
//  PXColorPickerView.m
//  Photon
//
//  Created by Logan Collins on 3/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXColorPickerView.h"
#import "PXColorWell.h"


@interface PXColorWellCell ()
- (void)closePicker;
@end


@implementation PXColorPickerView

@synthesize colorWellCell=_colorWellCell;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_colorWellCell = nil;
		hoverLocation.x = -1;
		hoverLocation.y = -1;
		_allowsTransparent = NO;
		[self updateTrackingAreas];
    }
    return self;
}

- (BOOL)isFlipped {
	return YES;
}

- (void)drawRect:(NSRect)rect {
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.5] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(4.0, 4.5) toPoint:NSMakePoint(6.0 + 157.0, 4.5)];
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(4.5, 5.0) toPoint:NSMakePoint(4.5, 5.0 + 131.0)];
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(5.5 + 157.0, 5.0) toPoint:NSMakePoint(5.5 + 157.0, 5.0 + 131.0)];
	[[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(4.0, 5.5 + 131.0) toPoint:NSMakePoint(6.0 + 157.0, 5.5 + 131.0)];
	
	NSBezierPath *border = [NSBezierPath bezierPathWithRect:NSMakeRect(5.0, 5.0, 157.0, 131.0)];
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.4 alpha:1.0]];
	[gradient drawInBezierPath:border angle:90.0];
	
	NSInteger i, j;
	CGFloat hue, saturation, brightness;
	
	// Transparent
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:NSMakeRect(5.0 + 1.0, 5.0 + 1.0, 12.0, 12.0)];
	if (_allowsTransparent)
		[[NSColor redColor] set];
	else
		[[NSColor colorWithCalibratedHue:1.0 saturation:1.0 brightness:1.0 alpha:0.5] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(5.0 + 1.0 + 12.0, 5.0 + 1.0) toPoint:NSMakePoint(5.0 + 1.0, 5.0 + 1.0 + 12.0)];
	
	// Monotones
	for (i=0; i<11; i++) {
		brightness = 1.0 - ((CGFloat)i / 10.0);
		[[NSColor colorWithCalibratedWhite:brightness alpha:1.0] set];
		[NSBezierPath fillRect:NSMakeRect(5.0 + 12.0*(i+1) + 1.0*(i+2), 5.0 + 1.0, 12.0, 12.0)];
	}
	
	// Brightness Scale
	for (i=0; i<12; i++) {
		hue = ((CGFloat)i / 12.0);
		
		for (j=0; j<5; j++) {
			brightness = 0.2 + ((CGFloat)j / 5.0);
			[[NSColor colorWithCalibratedHue:hue saturation:1.0 brightness:brightness alpha:1.0] set];
			[NSBezierPath fillRect:NSMakeRect(5.0 + 12.0*i + 1.0*(i+1), 5.0 + 12.0*(j+1) + 1.0*(j+2), 12.0, 12.0)];
		}
	}
	
	// Saturation Scale
	for (i=0; i<12; i++) {
		hue = ((CGFloat)i / 12.0);
		
		for (j=5; j<9; j++) {
			saturation = 0.8 - ((CGFloat)(j-5) / 5.0);
			[[NSColor colorWithCalibratedHue:hue saturation:saturation brightness:1.0 alpha:1.0] set];
			[NSBezierPath fillRect:NSMakeRect(5.0 + 12.0*i + 1.0*(i+1), 5.0 + 12.0*(j+1) + 1.0*(j+2), 12.0, 12.0)];
		}
	}
	
	if (hoverLocation.x > -1 && hoverLocation.y > -1 && hoverLocation.x < 12 && hoverLocation.y < 12) {
		[[NSColor whiteColor] set];
		[NSBezierPath strokeRect:NSInsetRect(NSMakeRect(5.0 + 12.0*hoverLocation.x + 1.0*(hoverLocation.x+1), 5.0 + 12.0*hoverLocation.y + 1.0*(hoverLocation.y+1), 12.0, 12.0), -0.5, -0.5)];
	}
	
	if (hoverShowColors) {
		NSRect colorsSelectRect = NSMakeRect(0.0, 140.0, NSWidth([self bounds]), 21.0);
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedHue:0.64 saturation:0.88 brightness:0.95 alpha:1.0] endingColor:[NSColor colorWithCalibratedHue:0.64 saturation:0.94 brightness:0.91 alpha:1.0]];
		[gradient drawInRect:colorsSelectRect angle:90.0];
	}
	
	NSImage *colorsImage = [[NSImage imageNamed:NSImageNameColorPanel] copy];
	[colorsImage setSize:NSMakeSize(16.0, 16.0)];
	[colorsImage drawInRect:NSMakeRect(4.0, 142.0, [colorsImage size].width, [colorsImage size].height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
	NSString *colorsString = [NSString stringWithFormat:@"Show Colors"];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSFont systemFontOfSize:11.0], NSFontAttributeName,
								(hoverShowColors ? [NSColor whiteColor] : [NSColor blackColor]), NSForegroundColorAttributeName,
								nil];
	NSRect colorsStringRect = NSMakeRect(4.0 + [colorsImage size].width + 4.0, 143.0 + round(([colorsImage size].height-[colorsString sizeWithAttributes:attributes].height)/2.0), 157.0 - ([colorsImage size].width + 12.0), [colorsString sizeWithAttributes:attributes].height);
	[colorsString drawInRect:colorsStringRect withAttributes:attributes];
}

- (void)mouseEntered:(NSEvent *)theEvent {
	NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	hoverShowColors = NO;
	NSInteger i, j;
	for (i=0; i<12; i++) {
		for (j=0; j<10; j++) {
			NSRect rect = NSMakeRect(5.0 + 12.0*i + 1.0*(i+1), 5.0 + 12.0*j + 1.0*(j+1), 12.0, 12.0);
			if (NSPointInRect(thePoint, rect)) {
				if (i==0 && j==0 && !_allowsTransparent) {
					hoverLocation.x = -1;
					hoverLocation.y = -1;
					[self setNeedsDisplay:YES];
					return;
				}
				hoverLocation.x = i;
				hoverLocation.y = j;
				[self setNeedsDisplay:YES];
				return;
			}
		}
	}
	hoverLocation.x = -1;
	hoverLocation.y = -1;
	hoverShowColors = NSPointInRect(thePoint, NSMakeRect(0.0, 140.0, NSWidth([self bounds]), 21.0));
	[self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent {
	NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	hoverShowColors = NO;
	NSInteger i, j;
	for (i=0; i<12; i++) {
		for (j=0; j<10; j++) {
			NSRect rect = NSMakeRect(5.0 + 12.0*i + 1.0*(i+1), 5.0 + 12.0*j + 1.0*(j+1), 13.0, 13.0);
			if (NSPointInRect(thePoint, rect)) {
				if (i==0 && j==0 && !_allowsTransparent) {
					hoverLocation.x = -1;
					hoverLocation.y = -1;
					[self setNeedsDisplay:YES];
					return;
				}
				hoverLocation.x = i;
				hoverLocation.y = j;
				[self setNeedsDisplay:YES];
				return;
			}
		}
	}
	hoverLocation.x = -1;
	hoverLocation.y = -1;
	hoverShowColors = NSPointInRect(thePoint, NSMakeRect(0.0, 140.0, NSWidth([self bounds]), 21.0));
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
	hoverLocation.x = -1;
	hoverLocation.y = -1;
	hoverShowColors = NO;
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
	NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	NSInteger i, j;
	
	// Transparent
	if (_allowsTransparent && NSPointInRect(thePoint, NSMakeRect(5.0 + 1.0, 5.0 + 1.0, 13.0, 13.0))) {
		[[self colorWellCell] setColor:nil];
		[NSApp sendAction:[[self colorWellCell] action] to:[[self colorWellCell] target] from:[self colorWellCell]];
		[[self colorWellCell] closePicker];
		return;
	}
	
	// Monotones
	for (i=0; i<11; i++) {
		NSRect rect = NSMakeRect(5.0 + 12.0*(i+1) + 1.0*(i+2), 5.0 + 1.0, 13.0, 13.0);
		if (NSPointInRect(thePoint, rect)) {
			CGFloat brightness = 1.0 - ((CGFloat)i / 10.0);
			[[self colorWellCell] setColor:[NSColor colorWithCalibratedWhite:brightness alpha:1.0]];
			[NSApp sendAction:[[self colorWellCell] action] to:[[self colorWellCell] target] from:[self colorWellCell]];
			[[self colorWellCell] closePicker];
			return;
		}
	}
	
	// Brightness Scale
	for (i=0; i<12; i++) {
		CGFloat hue = (((CGFloat)(i) * 1.0) / 13.0);
		for (j=0; j<5; j++) {
			NSRect rect = NSMakeRect(5.0 + 12.0*i + 1.0*(i+1), 5.0 + 12.0*(j+1) + 1.0*(j+2), 13.0, 13.0);
			if (NSPointInRect(thePoint, rect)) {
				CGFloat brightness = 0.2 + ((CGFloat)j / 5.0);
				[[self colorWellCell] setColor:[NSColor colorWithCalibratedHue:hue saturation:1.0 brightness:brightness alpha:1.0]];
				[NSApp sendAction:[[self colorWellCell] action] to:[[self colorWellCell] target] from:[self colorWellCell]];
				[[self colorWellCell] closePicker];
				return;
			}
		}
	}
	
	// Saturation Scale
	for (i=0; i<12; i++) {
		CGFloat hue = (((CGFloat)(i) * 1.0) / 13.0);
		for (j=5; j<9; j++) {
			NSRect rect = NSMakeRect(5.0 + 12.0*i + 1.0*(i+1), 5.0 + 12.0*(j+1) + 1.0*(j+2), 13.0, 13.0);
			if (NSPointInRect(thePoint, rect)) {
				CGFloat saturation = 0.8 - ((CGFloat)(j-5) / 5.0);
				[[self colorWellCell] setColor:[NSColor colorWithCalibratedHue:hue saturation:saturation brightness:1.0 alpha:1.0]];
				[NSApp sendAction:[[self colorWellCell] action] to:[[self colorWellCell] target] from:[self colorWellCell]];
				[[self colorWellCell] closePicker];
				return;
			}
		}
	}
	
	// Show Colors
	if (NSPointInRect(thePoint, NSMakeRect(0.0, 140.0, NSWidth([self bounds]), 21.0))) {
		NSColorPanel *panel = [NSColorPanel sharedColorPanel];
		[panel setTarget:[self colorWellCell]];
		[panel setAction:@selector(changeColor:)];
		[panel makeKeyAndOrderFront:self];
	}
	
	[[self colorWellCell] closePicker];
	[NSApp sendAction:[[self colorWellCell] action] to:[[self colorWellCell] target] from:[self colorWellCell]];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	[self mouseMoved:theEvent];
}

- (BOOL)allowsTransparent {
	return _allowsTransparent;
}

- (void)setAllowsTransparent:(BOOL)flag {
	[self willChangeValueForKey:@"allowsTransparent"];
	_allowsTransparent = flag;
	[self didChangeValueForKey:@"allowsTransparent"];
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)becomeFirstResponder { return YES; }

- (void)updateTrackingAreas {
	if (boundsTrackingArea) {
		[self removeTrackingArea:boundsTrackingArea];
		boundsTrackingArea = nil;
	}
	
	boundsTrackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect] options:(NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveInActiveApp) owner:self userInfo:nil];
	[self addTrackingArea:boundsTrackingArea];
}

@end
