//
//  PXAnchoredPopUpButton.m
//  Schoolhouse
//
//  Created by Logan Collins on 12/27/10.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXAnchoredPopUpButton.h"


@implementation PXAnchoredPopUpButton

@end


@implementation PXAnchoredPopUpButtonCell

- (NSRect)highlightRectForBounds:(NSRect)bounds {
	return bounds;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[super drawWithFrame:cellFrame inView:controlView];
	
	if ([self isHighlighted]) {
		[[NSColor colorWithCalibratedWhite:0.0 alpha:0.35] set];
		NSRectFillUsingOperation([self highlightRectForBounds:cellFrame], NSCompositeSourceOver);
	}
}

- (NSColor *)imageColor {
	NSColor *enabledImageColor = [NSColor colorWithCalibratedWhite:(72.0f / 255.0f) alpha:1.0];
	NSColor *disabledImageColor	= [enabledImageColor colorWithAlphaComponent:0.6];
	return [self isEnabled] ? enabledImageColor : disabledImageColor;
}

- (void)drawArrowInFrame:(NSRect)cellFrame {
	NSPoint drawPoint;
	drawPoint.x = NSMaxX(cellFrame) - 11.0;
	
	NSBundle *bundle = [NSBundle bundleForClass:[PXAnchoredPopUpButtonCell class]];		
	NSImage *pullDownArrow = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:@"PXAnchoredPopUpButtonPullDownArrow.pdf"]];
	
	NSSize size = [pullDownArrow size];
	NSRect imageBounds = NSMakeRect(0, 0, size.width, size.height);    
	
	NSImage *arrow = [pullDownArrow copy];
	[arrow lockFocus];
	[[self imageColor] set];
	NSRectFillUsingOperation(imageBounds, NSCompositeSourceAtop);
	[arrow unlockFocus];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy:0.0 yBy:cellFrame.size.height];
	[transform scaleXBy:1.0 yBy:-1.0];
	[transform concat];
	
	NSShadow *contentShadow = [[NSShadow alloc] init];
	[contentShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[contentShadow setShadowColor:[NSColor colorWithCalibratedWhite:(255.0f / 255.0f) alpha:0.75]];
	[contentShadow set];
	
	if ([self pullsDown]) {
		// Draw pull-down arrow
		drawPoint.y = roundf(cellFrame.size.height / 2) - 2;
		[arrow drawAtPoint:drawPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	else {
		// Draw bottom pop-up arrow
		drawPoint.y = roundf(cellFrame.size.height / 2) - 4;
		[arrow drawAtPoint:drawPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
		// Draw top pop-up arrow
		drawPoint.y -= 1;
		
		NSAffineTransform* transform2 = [NSAffineTransform transform];
		[transform2 translateXBy:0.0 yBy:cellFrame.size.height];
		[transform2 scaleXBy:1.0 yBy:-1.0];
		[transform2 concat];
		
		[arrow drawAtPoint:drawPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
		[transform2 invert];
		[transform2 concat];
	}
	
	[transform invert];
	[transform concat];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawBorderAndBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSColor *fillStop1 = [NSColor colorWithCalibratedWhite:(253.0f / 255.0f) alpha:1.0];
    NSColor *fillStop2 = [NSColor colorWithCalibratedWhite:(242.0f / 255.0f) alpha:1.0];
    NSColor *fillStop3 = [NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1.0];
	NSColor *fillStop4 = [NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1.0];
	
    NSGradient *fillGradient = [[NSGradient alloc] initWithColorsAndLocations:
								 fillStop1, (CGFloat)0.0,
								 fillStop2, (CGFloat)0.45454,
								 fillStop3, (CGFloat)0.45454,
								 fillStop4, (CGFloat)1.0,
								 nil];
	
	[fillGradient drawInRect:NSInsetRect(cellFrame, 1.0, 1.0) angle:90.0];
	
	// Draw borders
	//[[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
	//[NSBezierPath strokeLineFromPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y + 1.5) toPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width, cellFrame.origin.y + 1.5)];
	//[NSBezierPath strokeLineFromPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height - 1.5) toPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width, cellFrame.origin.y + cellFrame.size.height - 1.5)];
	//[NSBezierPath strokeLineFromPoint:NSMakePoint(cellFrame.origin.x + 0.5, cellFrame.origin.y) toPoint:NSMakePoint(cellFrame.origin.x + 0.5, cellFrame.origin.y + cellFrame.size.height)];
	//[NSBezierPath strokeLineFromPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 0.5, cellFrame.origin.y) toPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 0.5, cellFrame.origin.y + cellFrame.size.height)];
	
    NSGradient *borderGradient = [[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:
                                                                     [NSColor colorWithCalibratedWhite:0.5 alpha:0.0],
                                                                     [NSColor colorWithCalibratedWhite:0.5 alpha:1.0],
                                                                     [NSColor colorWithCalibratedWhite:0.5 alpha:0.0],
                                                                     nil]];
    if ([controlView autoresizingMask] & NSViewMaxXMargin) {
        [borderGradient drawInRect:NSMakeRect(cellFrame.size.width - 1.0, 2.0, 1.0, cellFrame.size.height - 4.0) angle:90.0];
    }
    else if ([controlView autoresizingMask] & NSViewMinXMargin) {
        [borderGradient drawInRect:NSMakeRect(0.0, 2.0, 1.0, cellFrame.size.height - 4.0) angle:90.0];
    }
    
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(cellFrame.origin.x + 1.0, cellFrame.origin.y + cellFrame.size.height - 2.5) toPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 1.0, cellFrame.origin.y + cellFrame.size.height - 2.5)];
    
	[self drawArrowInFrame:cellFrame];
}

- (NSRect)imageRectForBounds:(NSRect)theRect {
	NSRect imageRect = [super imageRectForBounds:theRect];
	
	if (imageRect.size.width < [self image].size.width) {
		imageRect.size.width += 2.0;
	}
	
	imageRect.origin.x += 2.0;
	
	return imageRect;
}

- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {	
	NSImage *image = [self image];
	
	if (image != nil) {
		[[NSGraphicsContext currentContext] saveGraphicsState];
		
		if ([[image name] isEqualToString:@"NSActionTemplate"]) {
			[image setSize:NSMakeSize(10.0, 10.0)];
		}
		
		NSImage *newImage = image;
		
		if ([image isTemplate]) {
			NSSize size = [image size];
			NSRect imageBounds = NSMakeRect(0.0, 0.0, size.width, size.height); 
			
			newImage = [image copy];
			[newImage lockFocus];
			[[self imageColor] set];
			NSRectFillUsingOperation(imageBounds, NSCompositeSourceAtop);
			[newImage unlockFocus];
		}
		
		NSAffineTransform *transform = [NSAffineTransform transform];
		[transform translateXBy:0.0 yBy:cellFrame.size.height];
		[transform scaleXBy:1.0 yBy:-1.0];
		[transform concat];
		
		[newImage drawInRect:[self imageRectForBounds:cellFrame] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
		
		[transform invert];
		[transform concat];
		
		[[NSGraphicsContext currentContext] restoreGraphicsState];
	}
}

@end
