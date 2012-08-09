//
//  PXFormatBarPopUpButton.m
//  LCToolkit
//
//  Created by Logan Collins on 3/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXFormatBarPopUpButton.h"


@implementation PXFormatBarPopUpButton

+ (void)initialize {
    if (self == [PXFormatBarPopUpButton class]) {
        [self setCellClass:[PXFormatBarPopUpButtonCell class]];
    }
}

- (id)initWithFrame:(NSRect)buttonFrame pullsDown:(BOOL)flag {
    self = [super initWithFrame:buttonFrame pullsDown:flag];
    if (self) {
        [[self cell] setControlSize:NSMiniControlSize];
        [[self cell] setFont:[NSFont controlContentFontOfSize:9.0]];
    }
    return self;
}

@end


@implementation PXFormatBarPopUpButtonCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSBezierPath *indention = [NSBezierPath bezierPathWithRoundedRect:NSOffsetRect(NSInsetRect(cellFrame, 1.5, 1.5), 0.0, 1.0) xRadius:2.0 yRadius:2.0];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, 1.5, 1.5) xRadius:2.0 yRadius:2.0];
    NSGradient *gradient;
    
    if ([self isHighlighted]) {
        [[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
        [indention stroke];
        
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.80 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.55 alpha:1.0]];
        [gradient drawInBezierPath:path angle:90.0];
        
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
        [path stroke];
    } else if ([[controlView window] isMainWindow]) {
        [[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
        [indention stroke];
        
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0]];
        [gradient drawInBezierPath:path angle:90.0];
        
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
        [path stroke];
    } else {        
        [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
        [indention stroke];
        
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]];
        [gradient drawInBezierPath:path angle:90.0];
        
        [[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
        [path stroke];
    }
    
    [self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSImage *arrow;
    
    if ([self pullsDown]) {
        arrow = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[PXFormatBarPopUpButtonCell class]] pathForImageResource:@"PXFormatBar-SingleArrow.pdf"]];
    }
    else {
        arrow = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[PXFormatBarPopUpButtonCell class]] pathForImageResource:@"PXFormatBar-DoubleArrow.pdf"]];
    }
    
    [arrow drawInRect:NSMakeRect(NSWidth(cellFrame)-([arrow size].width+1.0), floor((NSHeight(cellFrame)-[arrow size].height)/2.0), [arrow size].width, [arrow size].height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    if ([self image]) {
        NSImage *image = [self image];
        NSRect imageRect = NSMakeRect(6.0, floor((NSHeight(cellFrame) - [image size].height) / 2.0), [image size].width, [image size].height);
        [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    } else {
        NSString *title = [self title];
        NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [para setLineBreakMode:NSLineBreakByTruncatingTail];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:9.0], NSFontAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, para, NSParagraphStyleAttributeName, nil];
        NSRect titleRect = NSMakeRect(8.0, floor((NSHeight(cellFrame) - [title sizeWithAttributes:attributes].height) / 2.0), NSWidth(cellFrame)-(8.0+[arrow size].width+1.0), [title sizeWithAttributes:attributes].height);
        [title drawInRect:titleRect withAttributes:attributes];
    }
}

@end
