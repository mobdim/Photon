//
//  PXFormatBar.m
//  Photon
//
//  Created by Logan Collins on 3/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXFormatBar.h"
#import "PXFormatBar_Private.h"

#import "PXFormatBarItem.h"


NSString * const PXFormatBarSeparatorItemIdentifier = @"PXFormatBarSeparatorItem";
NSString * const PXFormatBarFlexibleSpaceItemIdentifier = @"PXFormatBarFlexibleSpaceItem";


@implementation PXFormatBar {
    NSArray *itemIdentifiers;
    NSDictionary *items;
    NSArray *visibleItems;
}

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        itemIdentifiers = [[NSArray alloc] init];
		items = [[NSDictionary alloc] init];
		visibleItems = [[NSArray alloc] init];
		
		[self setPostsFrameChangedNotifications:YES];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	if ([self window]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
	}
	
	if (newWindow) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChange:) name:NSViewFrameDidChangeNotification object:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:) name:NSWindowDidBecomeKeyNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:) name:NSWindowDidResignKeyNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:) name:NSWindowDidBecomeMainNotification object:[self window]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidUpdate:) name:NSWindowDidResignMainNotification object:[self window]];
		
		[self rearrangeItems];
	}
}

- (void)frameDidChange:(NSNotification *)notification {
	[self rearrangeItems];
}

- (void)windowDidUpdate:(NSNotification *)notification {
	[self setNeedsDisplay:YES];
}

- (NSArray *)items {
	NSMutableArray *theItems = [NSMutableArray arrayWithCapacity:[itemIdentifiers count]];
	for (NSString *identifier in itemIdentifiers) {
		[theItems addObject:[items objectForKey:identifier]];
	}
	return [theItems copy];
}

- (NSArray *)visibleItems {
	return [visibleItems copy];
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.3] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX([self bounds]), NSMinY([self bounds]) + 0.5) toPoint:NSMakePoint(NSMaxX([self bounds]), NSMinY([self bounds]) + 0.5)];
	
	[[NSColor colorWithCalibratedWhite:0.4 alpha:1.0] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX([self bounds]), NSMaxY([self bounds]) - 0.5) toPoint:NSMakePoint(NSMaxX([self bounds]), NSMaxY([self bounds]) - 0.5)];
	
	
	NSInteger flexibleCount = 0;
	CGFloat itemsWidth = 15.0;
	for (NSString *identifier in itemIdentifiers) {
		if ([identifier isEqualToString:PXFormatBarSeparatorItemIdentifier]) {
			itemsWidth += 16.0;
		}
		else if ([identifier isEqualToString:PXFormatBarFlexibleSpaceItemIdentifier]) {
			flexibleCount++;
		}
		else {
			PXFormatBarItem *item = [items objectForKey:identifier];
			itemsWidth += [self sizeForItem:item].width + 5.0;
		}
	}
	
	CGFloat remainingSpace = NSWidth([self bounds]) - itemsWidth;
	CGFloat flexibleSpaceSize = ((remainingSpace > 0.0) ? (remainingSpace / flexibleCount) : 0.0);
	CGFloat xPos = 15.0;
	for (NSString *itemIdentifier in itemIdentifiers) {
		if ([itemIdentifier isEqualToString:PXFormatBarSeparatorItemIdentifier]) {
			[[NSColor colorWithCalibratedWhite:0.4 alpha:1.0] set];
			[NSBezierPath strokeLineFromPoint:NSMakePoint(xPos + 5.5, NSMinY([self bounds]) + 4.0) toPoint:NSMakePoint(xPos + 5.5, NSMaxY([self bounds]) - 4.0)];
			
			xPos += 16.0;
		}
		else if ([itemIdentifier isEqualToString:PXFormatBarFlexibleSpaceItemIdentifier]) {
			xPos += flexibleSpaceSize;
		}
		else {
			PXFormatBarItem *item = [items objectForKey:itemIdentifier];
			
			if ([item label]) {
				NSString *label = [item label];
				NSDictionary *labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
												 [NSFont systemFontOfSize:9.0], NSFontAttributeName,
												 [NSColor colorWithCalibratedWhite:0.0 alpha:1.0], NSForegroundColorAttributeName,
												 nil];
				NSSize labelSize = [label sizeWithAttributes:labelAttributes];
				NSRect labelRect = NSMakeRect(xPos + 1.0, round((NSHeight([self bounds]) - labelSize.height) / 2.0) - 1.0, labelSize.width, labelSize.height);
				[label drawInRect:labelRect withAttributes:labelAttributes];
				
				xPos += ceil(labelSize.width) + 3.0;
			}
			
			if ([item image]) {
				NSImage *image = [[item image] copy];
				
				NSSize imageSize = [image size];
				NSRect imageRect = NSMakeRect(xPos, round((NSHeight([self bounds]) - [image size].height) / 2.0) - 1.0, imageSize.width, imageSize.height);
				[image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
				
				xPos += ceil(imageSize.width);
			}
			
			xPos += [[item view] bounds].size.width + 5.0;
		}
	}
}

- (BOOL)isFlipped {
	return YES;
}

- (BOOL)isOpaque {
	return YES;
}


#pragma mark -
#pragma mark Items

- (void)reloadItems {
	if ([self delegate]
		&& [[self delegate] respondsToSelector:@selector(formatBarDefaultItemIdentifiers:)]
		&& [[self delegate] respondsToSelector:@selector(formatBar:itemForItemIdentifier:)]) {
		
		// Remove all subviews
		[self setSubviews:[NSArray array]];
		
		// Get identifiers
		NSArray *identifiers = [[self delegate] formatBarDefaultItemIdentifiers:self];
		NSMutableArray *newItemIdentifiers = [NSMutableArray arrayWithCapacity:[identifiers count]];
		NSMutableDictionary *newItems = [NSMutableDictionary dictionaryWithCapacity:[identifiers count]];
		
		for (NSString *identifier in identifiers) {
			[newItemIdentifiers addObject:identifier];
			
			if ([identifier isEqualToString:PXFormatBarSeparatorItemIdentifier]
				|| [identifier isEqualToString:PXFormatBarFlexibleSpaceItemIdentifier]) {
				
			}
			else {
				PXFormatBarItem *item = [[self delegate] formatBar:self itemForItemIdentifier:identifier];
				if (item != nil) {
					[newItems setObject:item forKey:identifier];
				}
			}
		}
		
		itemIdentifiers = [newItemIdentifiers copy];
		items = [newItems copy];
		
		// Rebuild toolbar
		[self rearrangeItems];
	}
}

- (NSSize)sizeForItem:(PXFormatBarItem *)item {
	if ([item view]) { // View item
		NSSize size = [[item view] bounds].size;
		
		if ([item label]) {
			NSString *label = [item label];
			NSDictionary *labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSFont systemFontOfSize:9.0], NSFontAttributeName,
											 nil];
			NSSize labelSize = [label sizeWithAttributes:labelAttributes];
			size.width += ceil(labelSize.width) + 3.0;
		}
		
		if ([item image]) {
			NSImage *image = [item image];
			size.width += ceil([image size].width);
		}
		
		return size;
	}
	
	return NSZeroSize;
}

- (void)rearrangeItems {
	// Calculate total width of all items
	NSInteger flexibleCount = 0;
	CGFloat itemsWidth = 15.0;
	for (NSString *identifier in itemIdentifiers) {
		if ([identifier isEqualToString:PXFormatBarSeparatorItemIdentifier]) {
			itemsWidth += 16.0;
		}
		else if ([identifier isEqualToString:PXFormatBarFlexibleSpaceItemIdentifier]) {
			flexibleCount++;
		}
		else {
			PXFormatBarItem *item = [items objectForKey:identifier];
			itemsWidth += [self sizeForItem:item].width + 5.0;
		}
	}
	
	// Layout items
	NSMutableArray *newVisibleItems = [NSMutableArray array];
	CGFloat remainingSpace = NSWidth([self bounds]) - itemsWidth;
	
	if (remainingSpace >= 0) { // No clipping necessary, all items will fit.
		CGFloat flexibleSpaceSize = remainingSpace / flexibleCount;
		CGFloat xPos = 15.0;
		
		for (NSString *identifier in itemIdentifiers) {
			if ([identifier isEqualToString:PXFormatBarSeparatorItemIdentifier]) {
				xPos += 16.0;
			}
			else if ([identifier isEqualToString:PXFormatBarFlexibleSpaceItemIdentifier]) {
				xPos += flexibleSpaceSize;
			}
			else {
				PXFormatBarItem *item = [items objectForKey:identifier];
				
				if (item != nil) {
					NSSize itemSize = [self sizeForItem:item];
					
					NSPoint newOrigin;
					newOrigin.x = round(xPos);
					newOrigin.y = ceil((NSHeight([self bounds]) - itemSize.height) / 2.0) - 1.0;
					
					if ([item view]) { // View item
						if ([item label]) {
							NSString *label = [item label];
							NSDictionary *labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
															 [NSFont systemFontOfSize:9.0], NSFontAttributeName,
															 nil];
							NSSize labelSize = [label sizeWithAttributes:labelAttributes];
							newOrigin.x += ceil(labelSize.width) + 3.0;
						}
						
						if ([item image]) {
							NSImage *image = [item image];
							newOrigin.x += ceil([image size].width);
						}
						
						NSView *view = [item view];
						if ([view superview] != self) {
							if ([view superview]) {
								[view removeFromSuperview];
							}
							[self addSubview:view];
						}
						[view setFrameOrigin:newOrigin];
					}
					xPos += itemSize.width + 5.0;
					
					[newVisibleItems addObject:item];
				}
			}
		}
	}
	else { // Clipping required, some items will overflow.
		CGFloat xPos = 15.0;
		BOOL limitReached = NO;
		
		for (NSString *identifier in itemIdentifiers) {
			if ([identifier isEqualToString:PXFormatBarSeparatorItemIdentifier]) {
				if (!limitReached && xPos + 16.0 <= NSWidth([self bounds])) {
					xPos += 16.0;
				}
				else {
					if (!limitReached) {
						limitReached = YES;
					}
				}
			}
			else if ([identifier isEqualToString:PXFormatBarFlexibleSpaceItemIdentifier] && limitReached) {
				
			}
			else {
				PXFormatBarItem *item = [items objectForKey:identifier];
				
				if (item != nil) {
					NSSize itemSize = [self sizeForItem:item];
					
					if (!limitReached && xPos + itemSize.width + 5.0 <= NSWidth([self bounds])) {
						NSPoint newOrigin;
						newOrigin.x = round(xPos);
						newOrigin.y = ceil((NSHeight([self bounds]) - itemSize.height) / 2.0) + 1.0;
						
						if ([item view]) { // View item
							if ([item label]) {
								NSString *label = [item label];
								NSDictionary *labelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
																 [NSFont systemFontOfSize:9.0], NSFontAttributeName,
																 nil];
								NSSize labelSize = [label sizeWithAttributes:labelAttributes];
								newOrigin.x += ceil(labelSize.width) + 3.0;
							}
							
							if ([item image]) {
								NSImage *image = [item image];
								newOrigin.x += ceil([image size].width);
							}
							
							NSView *view = [item view];
							if ([view superview] != self) {
								if ([view superview]) {
									[view removeFromSuperview];
								}
								[self addSubview:view];
							}
							[view setFrameOrigin:newOrigin];
						}
						xPos += itemSize.width + 5.0;
						
						[newVisibleItems addObject:item];
					}
					else {
						if (!limitReached) {
							limitReached = YES;
						}
					}
				}
			}
		}
	}
	
	visibleItems = [newVisibleItems copy];
}

@end
