//
//  PXFormatBarSegmentedControl.m
//  LCToolkit
//
//  Created by Logan Collins on 3/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXFormatBarSegmentedControl.h"


@implementation PXFormatBarSegmentedControl

+ (void)initialize {
    if (self == [PXFormatBarSegmentedControl class]) {
        [self setCellClass:[PXFormatBarSegmentedCell class]];
    }
}

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[[self cell] setControlSize:NSMiniControlSize];
	}
	return self;
}

@end


@interface NSSegmentedCell (LCPrivate)

- (NSUInteger)_trackingSegment;

@end



@implementation PXFormatBarSegmentedCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSRect outerRect = NSOffsetRect(NSInsetRect(cellFrame, 0.5, 1.5), 0.0, 1.0);
	NSRect innerRect = NSInsetRect(cellFrame, 0.5, 1.5);
	
	if ([self segmentCount] == 0)
		return;
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	CGFloat xPos;
	NSRect rect;
	NSRect aRect;
	NSBezierPath *innerPath;
	NSBezierPath *outerPath;
    CGFloat radius = 2.0;
	CGFloat aRadius;
	
	NSUInteger trackingSegment = 0;
	if ([self respondsToSelector:@selector(_trackingSegment)]) {
		trackingSegment = [self _trackingSegment];
	}
    
	
	// Draw left segment
	rect = NSMakeRect(NSMinX(outerRect), NSMinY(outerRect), [self widthForSegment:0]+1.0, NSHeight(outerRect));
	
	outerPath = [NSBezierPath bezierPath];
	aRadius = MIN(radius, 0.5f * MIN(NSWidth(rect), NSHeight(rect)));
	aRect = NSInsetRect(rect, aRadius, aRadius);
	[outerPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(aRect), NSMinY(aRect)) radius:aRadius startAngle:180.0 endAngle:270.0];
	[outerPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
	[outerPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
	[outerPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(aRect), NSMaxY(aRect)) radius:aRadius startAngle:90.0 endAngle:180.0];
	[outerPath closePath];
	
	rect = NSMakeRect(NSMinX(innerRect), NSMinY(innerRect), [self widthForSegment:0]+1.0, NSHeight(innerRect));
	
	innerPath = [NSBezierPath bezierPath];
	aRadius = MIN(radius, 0.5f * MIN(NSWidth(rect), NSHeight(rect)));
	aRect = NSInsetRect(rect, aRadius, aRadius);
	[innerPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(aRect), NSMinY(aRect)) radius:aRadius startAngle:180.0 endAngle:270.0];
	[innerPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
	[innerPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
	[innerPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(aRect), NSMaxY(aRect)) radius:aRadius startAngle:90.0 endAngle:180.0];
	[innerPath closePath];
	
	if ([[controlView window] isMainWindow]) {
		[[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
	}
	else {
		[[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
	}
	[outerPath stroke];
	
	if (trackingSegment == 0 && [self isSelectedForSegment:0]) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.40 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else if (trackingSegment == 0) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.80 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.55 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else if ([self isSelectedForSegment:0] && [[controlView window] isMainWindow]) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.45 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else if ([[controlView window] isMainWindow]) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else if ([self isSelectedForSegment:0]) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.50 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	}
	
	if ([[controlView window] isMainWindow]) {
		[[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
	}
	else {
		[[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
	}
	[innerPath stroke];
	
	
	// Draw right segment
	xPos = NSMinX(outerRect);
	for (NSUInteger i=0; i<[self segmentCount]-1; i++) {
		xPos += [self widthForSegment:i]+1.0;
	}
	rect = NSMakeRect(xPos, NSMinY(outerRect), [self widthForSegment:[self segmentCount]-1]+1.0, NSHeight(outerRect));
	
	outerPath = [NSBezierPath bezierPath];
	aRadius = MIN(radius, 0.5f * MIN(NSWidth(rect), NSHeight(rect)));
	aRect = NSInsetRect(rect, aRadius, aRadius);
	[outerPath moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
	[outerPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(aRect), NSMinY(aRect)) radius:aRadius startAngle:270.0 endAngle:360.0];
	[outerPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(aRect), NSMaxY(aRect)) radius:aRadius startAngle:0.0 endAngle:90.0];
	[outerPath lineToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];
	[outerPath closePath];
	
	xPos = NSMinX(innerRect);
	for (NSUInteger i=0; i<[self segmentCount]-1; i++) {
		xPos += [self widthForSegment:i]+1.0;
	}
	rect = NSMakeRect(xPos, NSMinY(innerRect), [self widthForSegment:[self segmentCount]-1]+1.0, NSHeight(innerRect));
	
	innerPath = [NSBezierPath bezierPath];
	aRadius = MIN(radius, 0.5f * MIN(NSWidth(rect), NSHeight(rect)));
	aRect = NSInsetRect(rect, aRadius, aRadius);
	[innerPath moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
	[innerPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(aRect), NSMinY(aRect)) radius:aRadius startAngle:270.0 endAngle:360.0];
	[innerPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(aRect), NSMaxY(aRect)) radius:aRadius startAngle:0.0 endAngle:90.0];
	[innerPath lineToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];
	[innerPath closePath];
	
	if ([[controlView window] isMainWindow]) {
		[[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
	}
	else {
		[[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
	}
	[outerPath stroke];
	
	if (trackingSegment == [self segmentCount]-1 && [self isSelectedForSegment:[self segmentCount]-1]) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.40 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else if (trackingSegment == [self segmentCount]-1) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.80 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.55 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else if ([self isSelectedForSegment:[self segmentCount]-1] && [[controlView window] isMainWindow]) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.45 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else if ([[controlView window] isMainWindow]) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else if ([self isSelectedForSegment:[self segmentCount]-1]) {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.50 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	} else {
		NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]];
		[gradient drawInBezierPath:innerPath angle:90.0];
	}
	
	if ([[controlView window] isMainWindow]) {
		[[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
	}
	else {
		[[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
	}
	[innerPath stroke];
	
	
	// Draw middle segments
	for (NSUInteger segment=1; segment<[self segmentCount]-1; segment++) {
		xPos = NSMinX(outerRect);
		for (NSUInteger i=0; i<segment; i++) {
			xPos += [self widthForSegment:i]+1.0;
		}
		rect = NSMakeRect(xPos, NSMinY(outerRect), [self widthForSegment:segment]+1.0, NSHeight(outerRect));
		
		outerPath = [NSBezierPath bezierPath];
		[outerPath moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
		[outerPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
		[outerPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
		[outerPath lineToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];
		[outerPath closePath];
		
		xPos = NSMinX(innerRect);
		for (NSUInteger i=0; i<segment; i++) {
			xPos += [self widthForSegment:i]+1.0;
		}
		rect = NSMakeRect(xPos, NSMinY(innerRect), [self widthForSegment:segment]+1.0, NSHeight(innerRect));
		
		innerPath = [NSBezierPath bezierPath];
		[innerPath moveToPoint:NSMakePoint(NSMinX(rect), NSMinY(rect))];
		[innerPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect))];
		[innerPath lineToPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
		[innerPath lineToPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect))];
		[innerPath closePath];
		
		if ([[controlView window] isMainWindow]) {
			[[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
		}
		else {
			[[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
		}
		[outerPath stroke];
		
		if (trackingSegment == segment && [self isSelectedForSegment:segment]) {
			NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.40 alpha:1.0]];
			[gradient drawInBezierPath:innerPath angle:90.0];
		} else if (trackingSegment == segment) {
			NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.80 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.55 alpha:1.0]];
			[gradient drawInBezierPath:innerPath angle:90.0];
		} else if ([self isSelectedForSegment:segment] && [[controlView window] isMainWindow]) {
			NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.45 alpha:1.0]];
			[gradient drawInBezierPath:innerPath angle:90.0];
		} else if ([[controlView window] isMainWindow]) {
			NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0]];
			[gradient drawInBezierPath:innerPath angle:90.0];
		} else if ([self isSelectedForSegment:segment]) {
			NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.50 alpha:1.0]];
			[gradient drawInBezierPath:innerPath angle:90.0];
		} else {
			NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]];
			[gradient drawInBezierPath:innerPath angle:90.0];
		}
		
		if ([[controlView window] isMainWindow]) {
			[[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
		}
		else {
			[[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
		}
		[innerPath stroke];
	}
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	[self drawInteriorWithFrame:NSInsetRect(cellFrame, 0.0, 2.0) inView:controlView];
}

@end
