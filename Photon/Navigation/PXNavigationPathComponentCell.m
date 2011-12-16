//
//  PXNavigationPathComponentCell.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationPathComponentCell.h"


@implementation PXNavigationPathComponentCell

@synthesize firstItem;
@synthesize lastItem;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	CGFloat xMinOffset = 0.0;
	
	if (!self.lastItem) {
		NSImage *separator = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[PXNavigationPathComponentCell class]] pathForImageResource:@"PXPathComponentSeparator.pdf"]];
		NSRect separatorRect = NSMakeRect(cellFrame.origin.x + cellFrame.size.width - 7.0, cellFrame.origin.y + round((cellFrame.size.height - 18.0) / 2.0), 7.0, 18.0);
		[separator drawInRect:separatorRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	NSRect interiorRect = NSMakeRect(cellFrame.origin.x + xMinOffset, cellFrame.origin.y, cellFrame.size.width - xMinOffset, cellFrame.size.height - 1.0);
	
	[self drawInteriorWithFrame:NSInsetRect(interiorRect, 5.0, 0.0) inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowBlurRadius:0.0];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.6]];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[shadow set];
	
	CGFloat xMinOffset = 0.0;
	CGFloat xMaxOffset = 0.0;
	
	if ([self image]) {
		NSImage *image = [[self image] copy];
		[image setSize:NSMakeSize(16.0, 16.0)];
		
		NSSize imageSize = [image size];
		
		NSImageCell *imageCell = [[NSImageCell alloc] initImageCell:image];
		
		NSRect imageRect = NSMakeRect(cellFrame.origin.x + xMinOffset, cellFrame.origin.y + round((cellFrame.size.height - imageSize.height) / 2.0), imageSize.width, imageSize.width);
		[imageCell drawWithFrame:imageRect inView:controlView];
		
		xMinOffset += imageSize.width + 3.0;
	}
	
	NSString *title = [self title];
	NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[para setLineBreakMode:NSLineBreakByTruncatingTail];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSFont systemFontOfSize:11.0], NSFontAttributeName,
								[NSColor blackColor], NSForegroundColorAttributeName,
								para, NSParagraphStyleAttributeName,
								nil];
	
	NSSize titleSize = [title sizeWithAttributes:attributes];
	NSRect titleRect = NSMakeRect(cellFrame.origin.x + xMinOffset, cellFrame.origin.y + round((cellFrame.size.height - titleSize.height) / 2.0), cellFrame.size.width - (xMinOffset + xMaxOffset), titleSize.height);
	
    if (titleRect.size.width > 10.0) {
        [title drawInRect:titleRect withAttributes:attributes];
    }
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
	NSSize result = aRect.size;
	CGFloat minWidth = 10.0;
	
	if (!self.lastItem) {
		minWidth += 7.0;
	}
	
	if ([self image]) {
		minWidth += 16.0;
	}
    else {
        minWidth += 20.0;
    }
	
	if (NSIsEmptyRect(aRect)) {
        result.width = minWidth;        
    }
	else {
		CGFloat naturalWidth = minWidth;
        
        if ([self image]) {
            naturalWidth += 3.0;
        }
		
		NSString *title = [self title];
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSFont systemFontOfSize:11.0], NSFontAttributeName,
									[NSColor blackColor], NSForegroundColorAttributeName,
									nil];
		
		naturalWidth += ceil([title sizeWithAttributes:attributes].width);
		
		result.width = MIN(naturalWidth, result.width);
		result.width = MAX(minWidth, result.width);
	}
	
	return result;
}

@end
