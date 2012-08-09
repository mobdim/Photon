//
//  PXFormatBarColorWell.m
//  LCToolkit
//
//  Created by Logan Collins on 3/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXFormatBarColorWell.h"


@implementation PXFormatBarColorWell

+ (void)initialize {
    if (self == [PXFormatBarColorWell class]) {
        [self setCellClass:[PXFormatBarColorWellCell class]];
    }
}

@end


@implementation PXFormatBarColorWellCell



#pragma mark -
#pragma mark Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect newFrame = NSMakeRect(NSMinX(cellFrame), NSMinY(cellFrame) + 1.0, NSWidth(cellFrame), NSHeight(cellFrame) - 2.0);
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(newFrame, 0.5, 0.5)];
    NSGradient *gradient = nil;
    
    if ([self isHighlighted]) {
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.80 alpha:1.0]
                                                 endingColor:[NSColor colorWithCalibratedWhite:0.55 alpha:1.0]];
        [gradient drawInBezierPath:path angle:-90.0];
        
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
        [path stroke];
    } else if ([[controlView window] isMainWindow]) {
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0]
                                                 endingColor:[NSColor colorWithCalibratedWhite:0.60 alpha:1.0]];
        [gradient drawInBezierPath:path angle:-90.0];
        
        [[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] set];
        [path stroke];
    } else {
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
                                                 endingColor:[NSColor colorWithCalibratedWhite:0.65 alpha:1.0]];
        [gradient drawInBezierPath:path angle:-90.0];
        
        [[NSColor colorWithCalibratedWhite:0.55 alpha:1.0] set];
        [path stroke];
    }
    
    if ([[controlView window] isMainWindow]) {
        [[NSColor colorWithCalibratedWhite:0.65 alpha:1.0] set];
    }
    else {
        [[NSColor colorWithCalibratedWhite:0.85 alpha:1.0] set];
    }
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame) + 0.5) toPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame) + 0.5)];
    
    [self drawInteriorWithFrame:newFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSBezierPath *fill = [NSBezierPath bezierPathWithRect:NSInsetRect(cellFrame, 2.0, 2.0)];
    NSBezierPath *stroke = [NSBezierPath bezierPathWithRect:NSInsetRect(cellFrame, 2.5, 2.5)];
    
    if (self.color) {
        [self.color set];
        [fill fill];
    }
    else {
        [[NSColor whiteColor] set];
        [fill fill];
        NSRect rect = NSInsetRect(cellFrame, 3.0, 3.0);
        [[NSColor redColor] set];
        [[NSColor redColor] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(rect), NSMinY(rect)) toPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect))];
    }
    
    if (![self isEnabled]) {
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] set];
        [stroke stroke];
    }
    else {
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] set];
        [stroke stroke];
    }
    
    if (self.textColorWell) {
        NSString *character = [NSString stringWithFormat:@"a"];
        NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [para setAlignment:NSCenterTextAlignment];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSFont fontWithName:@"Times New Roman" size:14.0], NSFontAttributeName,
                                    [self.textColorWell color], NSForegroundColorAttributeName,
                                    para, NSParagraphStyleAttributeName,
                                    nil];
        NSRect characterRect = NSMakeRect(5.0, ((NSHeight(cellFrame)-[character sizeWithAttributes:attributes].height) / 2.0), NSWidth(cellFrame) - 10.0, [character sizeWithAttributes:attributes].height + 2.0);
        [character drawInRect:characterRect withAttributes:attributes];
    }
}

@end
