//
//  PXTabBar.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXTabBar.h"
#import "PXTabBar_Private.h"
#import "PXTabBarItem.h"


NSString * const PXTabBarItemPropertyObservationContext = @"PXTabBarItemPropertyObservationContext";


@implementation PXTabBar {
    NSMutableArray *items;
    NSTrackingArea *trackingArea;
    PXTabBarItem *selectedItem;
    PXTabBarItem *mouseDownItem;
    BOOL drawMouseDownItemSelection;
    NSEvent *lastMouseDownEvent;
}

@synthesize delegate=_delegate;
@synthesize style=_style;
@synthesize cornerRadius=_cornerRadius;
@synthesize border=_border;

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        items = [[NSMutableArray alloc] init];
        
        [self updateTrackingAreas];
    }
    return self;
}

- (void)update {
    NSRect itemsRect = [self itemsRect];
    CGFloat xPos = itemsRect.origin.x;
    BOOL overflow = NO;
    NSMenu *overflowMenu = nil;
    
    for (PXTabBarItem *item in items) {
        CGFloat itemWidth = [self widthOfItem:item];
        if (overflow == NO && xPos + itemWidth <= itemsRect.origin.x + itemsRect.size.width) {
            xPos += itemWidth;
        }
        else {
            if (overflow == NO) {
                overflow = YES;
                overflowMenu = [[NSMenu alloc] init];
            }
            
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem bind:NSTitleBinding toObject:item withKeyPath:@"title" options:nil];
            [menuItem bind:NSImageBinding toObject:item withKeyPath:@"image" options:nil];
            
            if (selectedItem == item) {
                [menuItem setState:NSOnState];
            }
            
            [overflowMenu addItem:menuItem];
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    if ([self window] != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:[self window]];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:[self window]];
    }
    
    if (newWindow != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeMain:) name:NSWindowDidBecomeMainNotification object:newWindow];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeMain:) name:NSWindowDidResignMainNotification object:newWindow];
    }
}

- (void)windowDidChangeMain:(NSNotification *)notification {
    [self setNeedsDisplay:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == (__bridge void *)PXTabBarItemPropertyObservationContext) {
        [self setNeedsDisplay:YES];
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark -
#pragma mark Drawing

- (NSRect)borderRect {
    NSRect borderRect = NSInsetRect([self bounds], -0.5, -0.5);
    if (self.border != PXAppearanceBorderNone) {
        if (self.border & PXAppearanceBorderLeft) {
            borderRect.size.width -= 1.0;
            borderRect.origin.x += 1.0;
        }
        if (self.border & PXAppearanceBorderRight) {
            borderRect.size.width -= 1.0;
        }
        if (self.border & PXAppearanceBorderTop) {
            borderRect.size.height -= 1.0;
            borderRect.origin.y += 1.0;
        }
        if (self.border & PXAppearanceBorderBottom) {
            borderRect.size.height -= 1.0;
        }
    }
    return borderRect;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:self.cornerRadius yRadius:self.cornerRadius];
    [bezierPath addClip];
    
    NSRect borderRect = [self borderRect];
    
    if (self.style == PXTabBarStyleLight) {
        if ([[self window] isMainWindow]) {
            NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]
                                                                 endingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]];
            [gradient drawInRect:[self bounds] angle:90.0];
            
            if (self.border != PXAppearanceBorderNone) {
                [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
                NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:self.cornerRadius yRadius:self.cornerRadius];
                [bezierPath stroke];
            }
        }
        else {
            NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
                                                                 endingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]];
            [gradient drawInRect:[self bounds] angle:90.0];
            
            if (self.border != PXAppearanceBorderNone) {
                [[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
                NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:self.cornerRadius yRadius:self.cornerRadius];
                [bezierPath stroke];
            }
        }
        
        // Emboss
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.3] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(borderRect), NSMinY(borderRect) + 1.0) toPoint:NSMakePoint(NSMaxX(borderRect), NSMinY(borderRect) + 1.0)];
    }
    else if (self.style == PXTabBarStyleDark) {
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.25 alpha:1.0]
                                                             endingColor:[NSColor colorWithCalibratedWhite:0.15 alpha:1.0]];
        [gradient drawInRect:[self bounds] angle:90.0];
        
        if (self.border != PXAppearanceBorderNone) {
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
            NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:self.cornerRadius yRadius:self.cornerRadius];
            [bezierPath stroke];
        }
    }
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawItemsInRect:(NSRect)dirtyRect {
    // Draw items
    NSRect itemsRect = [self itemsRect];
    
    CGFloat xPos = itemsRect.origin.x;
    
    NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [para setAlignment:NSCenterTextAlignment];
    [para setLineBreakMode:NSLineBreakByTruncatingMiddle];
    
    
    NSRect borderRect = [self borderRect];
    
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    // Corner radius clipping mask
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:self.cornerRadius yRadius:self.cornerRadius];
    [bezierPath addClip];
    
    for (PXTabBarItem *item in items) {
        CGFloat itemWidth = [self widthOfItem:item];
        NSRect itemRect = NSMakeRect(xPos, 0.0, itemWidth, [self bounds].size.height);
        
        if ([items lastObject] != item) {
            itemRect.size.width -= 1.0;
        }
        
        // Draw selection
        BOOL isSelected = (selectedItem == item && !drawMouseDownItemSelection) || (mouseDownItem == item && drawMouseDownItemSelection == YES);
        if (isSelected) {
            [[NSGraphicsContext currentContext] saveGraphicsState];
            
            NSRectClip(itemRect);
            
            if (self.style == PXTabBarStyleLight) {
                if ([[self window] isMainWindow]) {
                    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]
                                                                         endingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]];
                    [gradient drawInRect:itemRect angle:90.0];
                    
                    if (self.border != PXAppearanceBorderNone) {
                        [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
                        NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:self.cornerRadius yRadius:self.cornerRadius];
                        [bezierPath stroke];
                    }
                }
                else {
                    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]
                                                                         endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]];
                    [gradient drawInRect:itemRect angle:90.0];
                    
                    if (self.border != PXAppearanceBorderNone) {
                        [[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
                        NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:self.cornerRadius yRadius:self.cornerRadius];
                        [bezierPath stroke];
                    }
                }
                
                // Emboss
                [[NSColor colorWithCalibratedWhite:1.0 alpha:0.3] set];
                [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(borderRect), NSMinY(borderRect) + 1.0) toPoint:NSMakePoint(NSMaxX(borderRect), NSMinY(borderRect) + 1.0)];
            }
            else if (self.style == PXTabBarStyleDark) {
                NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.15 alpha:1.0]
                                                                     endingColor:[NSColor colorWithCalibratedWhite:0.25 alpha:1.0]];
                [gradient drawInRect:itemRect angle:90.0];
                
                if (self.border != PXAppearanceBorderNone) {
                    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.3] set];
                    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:self.cornerRadius yRadius:self.cornerRadius];
                    [bezierPath stroke];
                }
            }
            
            [[NSGraphicsContext currentContext] restoreGraphicsState];
        }
        
        // Draw divider
        if ([items lastObject] != item) {
            NSRect dividerRect = NSMakeRect(itemRect.origin.x + itemRect.size.width, itemRect.origin.y, 1.0, itemRect.size.height);
            if (self.style == PXTabBarStyleLight) {
                [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
            }
            else if (self.style == PXTabBarStyleDark) {
                [[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
            }
            [NSBezierPath fillRect:dividerRect];
        }
        
        // Draw image
        NSImage *image = [[item image] copy];
        if (image != nil) {
            NSRect imageRect = NSMakeRect(itemRect.origin.x + round((itemRect.size.width - [image size].width) / 2.0), itemRect.origin.y + 4.0, [image size].width, [image size].height);
            
            if (self.style == PXTabBarStyleLight) {
                [image setTemplate:YES];
                NSImageCell *imageCell = [[NSImageCell alloc] initImageCell:image];
                [imageCell setBackgroundStyle:NSBackgroundStyleRaised];
                
                NSImage *finalImage = [[NSImage alloc] initWithSize:imageRect.size];
                [finalImage lockFocus];
                [imageCell drawWithFrame:NSMakeRect(0.0, 0.0, imageRect.size.width, imageRect.size.height) inView:self];
                [finalImage unlockFocus];
                
                [finalImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:(isSelected ? 1.0 : 0.75) respectFlipped:NO hints:nil];
            }
            else if (self.style == PXTabBarStyleDark) {
                NSGradient *topGradient = nil;
                NSGradient *bottomGradient = nil;
                if (isSelected) {
                    topGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedHue:(200.0/360.0) saturation:0.8 brightness:1.0 alpha:1.0]
                                                                endingColor:[NSColor colorWithCalibratedHue:(200.0/360.0) saturation:0.65 brightness:1.0 alpha:1.0]];
                    bottomGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedHue:(200.0/360.0) saturation:0.25 brightness:1.0 alpha:1.0]
                                                                   endingColor:[NSColor colorWithCalibratedHue:(200.0/360.0) saturation:0.65 brightness:1.0 alpha:1.0]];
                }
                else {
                    topGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0]
                                                                endingColor:[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.7 alpha:1.0]];
                    bottomGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedHue:(200.0/360.0) saturation:0.0 brightness:0.8 alpha:1.0]
                                                                   endingColor:[NSColor colorWithCalibratedHue:(200.0/360.0) saturation:0.0 brightness:0.7 alpha:1.0]];
                }
                
                NSImage *finalImage = [[NSImage alloc] initWithSize:imageRect.size];
                [finalImage lockFocus];
                
                [topGradient drawInRect:NSMakeRect(0.0, 0.0, [finalImage size].width, floor([finalImage size].height / 2.0)) angle:-90.0];
                [bottomGradient drawInRect:NSMakeRect(0.0, floor([finalImage size].height / 2.0), [finalImage size].width, ceil([finalImage size].height / 2.0)) angle:-90.0];
                
                [image drawInRect:NSMakeRect(0.0, 0.0, [finalImage size].width, [finalImage size].height) fromRect:NSZeroRect operation:NSCompositeDestinationIn fraction:1.0 respectFlipped:NO hints:nil];
                
                [finalImage unlockFocus];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                
                NSShadow *shadow = [[NSShadow alloc] init];
                [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.75]];
                [shadow setShadowBlurRadius:2.0];
                [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
                [shadow set];
                
                [finalImage drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
                
                [[NSGraphicsContext currentContext] restoreGraphicsState];
            }
        }
        
        // Draw title
        NSMutableDictionary *itemAttributes = nil;
        if (self.style == PXTabBarStyleLight) {
            itemAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSFont boldSystemFontOfSize:9.0], NSFontAttributeName,
                              [NSColor colorWithCalibratedWhite:0.4 alpha:1.0], NSForegroundColorAttributeName,
                              para, NSParagraphStyleAttributeName,
                              nil];
            
            // Draw selection
            if (isSelected) {
                [itemAttributes setObject:[NSColor colorWithCalibratedWhite:0.2 alpha:1.0] forKey:NSForegroundColorAttributeName];
            }
        }
        else if (self.style == PXTabBarStyleDark) {
            itemAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              [NSFont boldSystemFontOfSize:9.0], NSFontAttributeName,
                              [NSColor colorWithCalibratedWhite:0.6 alpha:1.0], NSForegroundColorAttributeName,
                              para, NSParagraphStyleAttributeName,
                              nil];
            
            // Draw selection
            if (isSelected) {
                [itemAttributes setObject:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
            }
        }
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        if (self.style == PXTabBarStyleLight) {
            [shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.6]];
            [shadow setShadowBlurRadius:0.0];
            [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        }
        else if (self.style == PXTabBarStyleDark) {
            [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.6]];
            [shadow setShadowBlurRadius:0.0];
            [shadow setShadowOffset:NSMakeSize(0.0, 1.0)];
        }
        [shadow set];
        
        NSString *text = [item title];
        NSSize textSize = [text sizeWithAttributes:itemAttributes];
        NSRect textRect = NSMakeRect(itemRect.origin.x + 5.0, itemRect.origin.y + itemRect.size.height - (textSize.height + 2.0), itemRect.size.width - 10.0, textSize.height);
        [text drawInRect:textRect withAttributes:itemAttributes];
        
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    
        xPos += itemWidth;
    }
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self drawBackgroundInRect:dirtyRect];
    [self drawItemsInRect:dirtyRect];
}

- (BOOL)isFlipped {
    return YES;
}


#pragma mark -
#pragma mark Events

- (void)updateTrackingAreas {
    if (trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
        trackingArea = nil;
    }
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect] options:(NSTrackingActiveInKeyWindow|NSTrackingMouseEnteredAndExited) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    lastMouseDownEvent = theEvent;
    
    PXTabBarItem *item = [self itemAtPoint:thePoint];
    if (item) {
        mouseDownItem = item;
        drawMouseDownItemSelection = YES;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (mouseDownItem) {
        PXTabBarItem *item = [self itemAtPoint:thePoint];
        if (item == mouseDownItem) {
            drawMouseDownItemSelection = YES;
        }
        else {
            drawMouseDownItemSelection = NO;
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (mouseDownItem) {
        PXTabBarItem *item = [self itemAtPoint:thePoint];
        if (item == mouseDownItem) {
            [self selectItem:item];
        }
    }
    
    lastMouseDownEvent = nil;
    mouseDownItem = nil;
    drawMouseDownItemSelection = NO;
    
    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (mouseDownItem) {
        PXTabBarItem *item = [self itemAtPoint:thePoint];
        if (item == mouseDownItem) {
            drawMouseDownItemSelection = YES;
        }
        else {
            drawMouseDownItemSelection = NO;
        }
    }
    
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    drawMouseDownItemSelection = NO;
    
    [self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark Items

- (NSRect)itemsRect {
    NSRect itemsRect = [self bounds];
    return itemsRect;
}

- (CGFloat)widthOfItem:(PXTabBarItem *)item {
    NSRect itemsRect = [self itemsRect];
    CGFloat width = round(itemsRect.size.width / (CGFloat)[items count]);
    NSUInteger remainder = (NSUInteger)itemsRect.size.width % [items count];
    NSUInteger index = [items indexOfObjectIdenticalTo:item];
    if (remainder > index) {
        width += 1.0;
    }
    return width;
}

- (PXTabBarItem *)itemAtPoint:(NSPoint)thePoint {
    NSRect itemsRect = [self itemsRect];
    
    CGFloat totalWidth = 0.0;
    BOOL overflow = NO;
    for (PXTabBarItem *item in items) {
        CGFloat itemWidth = [self widthOfItem:item];
        if (totalWidth + itemWidth <= itemsRect.size.width) {
            totalWidth += itemWidth;
        }
        else {
            overflow = YES;
            break;
        }
    }
    
    
    CGFloat xPos = itemsRect.origin.x;
    
    if (!overflow) {
        // Not overflowing
        xPos = itemsRect.origin.x + round((itemsRect.size.width - totalWidth) / 2.0);
    }
    
    for (PXTabBarItem *item in items) {
        CGFloat itemWidth = [self widthOfItem:item];
        NSRect itemRect = NSMakeRect(xPos, 0.0, itemWidth, [self bounds].size.height - 1.0);
        if (NSPointInRect(thePoint, itemRect)) {
            return item;
        }
        xPos += itemWidth;
    }
    
    return nil;
}

- (NSArray *)items {
    return [items copy];
}

- (void)setItems:(NSArray *)newItems {
    if (![items isEqualToArray:newItems]) {
        while ([[self items] count] > 0) {
            [self removeItemAtIndex:0];
        }
        
        for (PXTabBarItem *item in newItems) {
            [self addItem:item];
        }
    }
}

+ (NSSet *)keyPathsForValuesAffectingSelectedIndex {
    return [NSSet setWithObjects:@"selectedItem", nil];
}

- (PXTabBarItem *)selectedItem {
    return selectedItem;
}

- (void)setSelectedItem:(PXTabBarItem *)item {
    if (selectedItem != item) {
        [self willChangeValueForKey:@"selectedItem"];
        selectedItem = item;
        [self didChangeValueForKey:@"selectedItem"];
        [self update];
    }
}

- (NSUInteger)selectedIndex {
    return [items indexOfObjectIdenticalTo:selectedItem];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self selectItemAtIndex:selectedIndex];
}

- (void)addItem:(PXTabBarItem *)item {
    [self insertItem:item atIndex:[items count]];
}

- (void)insertItem:(PXTabBarItem *)item atIndex:(NSUInteger)index {
    [item addObserver:self forKeyPath:@"image" options:(NSKeyValueObservingOptionNew) context:(__bridge void *)PXTabBarItemPropertyObservationContext];
    [item addObserver:self forKeyPath:@"badgeValue" options:(NSKeyValueObservingOptionNew) context:(__bridge void *)PXTabBarItemPropertyObservationContext];
    
    [items insertObject:item atIndex:index];
    
    [self update];
}

- (void)removeItem:(PXTabBarItem *)item {
    NSUInteger index = [items indexOfObject:item];
    if (index != NSNotFound) {
        [self removeItemAtIndex:index];
    }
}

- (void)removeItemAtIndex:(NSUInteger)index {
    PXTabBarItem *item = [items objectAtIndex:index];
    
    if (item == selectedItem) {
        if (index < [items count]-1) {
            // Select next tab
            [self selectItemAtIndex:index+1];
        }
        else if (index > 0) {
            // Select previous tab
            [self selectItemAtIndex:index-1];
        }
        else {
            // Select nothing
            [self setSelectedItem:nil];
        }
    }
    
    [item removeObserver:self forKeyPath:@"image"];
    [item removeObserver:self forKeyPath:@"badgeValue"];
    
    [items removeObjectAtIndex:index];
    
    [self update];
}

- (void)selectItem:(PXTabBarItem *)item {
    if ([[self delegate] respondsToSelector:@selector(tabBar:shouldSelectItem:)]) {
        if (![[self delegate] tabBar:self shouldSelectItem:item]) {
            return;
        }
    }
    
    if ([[self delegate] respondsToSelector:@selector(tabBar:willSelectItem:)]) {
        [[self delegate] tabBar:self willSelectItem:item];
    }
    
    [self setSelectedItem:item];
    [self update];
    
    if ([[self delegate] respondsToSelector:@selector(tabBar:didSelectItem:)]) {
        [[self delegate] tabBar:self didSelectItem:item];
    }
}

- (void)selectItemAtIndex:(NSUInteger)index {
    PXTabBarItem *item = [items objectAtIndex:index];
    [self selectItem:item];
}

- (PXTabBarItem *)itemAtIndex:(NSUInteger)index {
    return [items objectAtIndex:index];
}

- (NSUInteger)indexOfItem:(PXTabBarItem *)item {
    return [items indexOfObjectIdenticalTo:item];
}

@end
