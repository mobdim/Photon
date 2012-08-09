//
//  PXFormatBarComboBox.m
//  LCToolkit
//
//  Created by Logan Collins on 3/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXFormatBarComboBox.h"


@implementation PXFormatBarComboBox

+ (void)initialize {
    if (self == [PXFormatBarComboBox class]) {
        [self setCellClass:[PXFormatBarComboBoxCell class]];
    }
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[self cell] setControlSize:NSMiniControlSize];
        [[self cell] setFont:[NSFont controlContentFontOfSize:9.0]];
        [[self cell] setDrawsBackground:NO];
    }
    return self;
}

@end


@implementation PXFormatBarComboBoxCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    // Draw button
    NSRect buttonRect = NSMakeRect(NSWidth(cellFrame) - 17.0, 1.0, 17.0, NSHeight(cellFrame) - 2.0);
    NSBezierPath *indention = [NSBezierPath bezierPathWithRoundedRect:NSOffsetRect(NSInsetRect(buttonRect, 0.5, 0.5), 0.0, 1.0) xRadius:2.0 yRadius:2.0];
    NSBezierPath *buttonPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(buttonRect, 0.5, 0.5) xRadius:2.0 yRadius:2.0];
    
    if ([self isHighlighted]) {
        [[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
        [indention stroke];
        
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.80 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.55 alpha:1.0]];
        [gradient drawInBezierPath:buttonPath angle:90.0];
        
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
        [buttonPath stroke];
    } else if ([[controlView window] isMainWindow]) {
        [[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
        [indention stroke];
        
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0]];
        [gradient drawInBezierPath:buttonPath angle:90.0];
        
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
        [buttonPath stroke];
    } else {        
        [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
        [indention stroke];
        
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]];
        [gradient drawInBezierPath:buttonPath angle:90.0];
        
        [[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
        [buttonPath stroke];
    }
    
    NSImage *arrow = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[PXFormatBarComboBoxCell class]] pathForImageResource:@"PXFormatBar-SingleArrow.pdf"]];
    [arrow drawInRect:NSMakeRect(NSWidth(cellFrame)-([arrow size].width+1.0), floor((NSHeight(cellFrame)-[arrow size].height)/2.0), [arrow size].width, [arrow size].height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    
    // Draw field
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    NSRect frameRect = NSMakeRect(0.0, 1.0, NSWidth(cellFrame) - 15.0, NSHeight(cellFrame) - 2.0);
    
    if ([[controlView window] isMainWindow]) {
        [[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
    }
    else {
        [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
    }
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(frameRect), NSMaxY(frameRect) + 0.5) toPoint:NSMakePoint(NSMaxX(frameRect), NSMaxY(frameRect) + 0.5)];
    
    [NSBezierPath clipRect:frameRect];
    
    
    NSGradient *innerGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
                                                              endingColor:[NSColor colorWithCalibratedWhite:0.85 alpha:1.0]];
    [innerGradient drawInRect:NSInsetRect(frameRect, 0.5, 0.5) angle:90.0];
    
    
    NSGradient *shadowGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.4]
                                                               endingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.0]];
    [shadowGradient drawInRect:NSMakeRect(NSMinX(frameRect), NSMinY(frameRect), NSWidth(frameRect), 3.0) angle:90.0];
    
    if ([[controlView window] isMainWindow]) {
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
    }
    else {
        [[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
    }
    [NSBezierPath strokeRect:NSInsetRect(frameRect, 0.5, 0.5)];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
    [self drawInteriorWithFrame:NSInsetRect(cellFrame, 0.0, 1.0) inView:controlView];
}

@end
