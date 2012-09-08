//
//  PXNavigationBackButtonCell.m
//  Photon
//
//  Created by Logan Collins on 9/7/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationBackButtonCell.h"


@implementation PXNavigationBackButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect bezelRect = NSMakeRect(frame.origin.x + 1.5, frame.origin.y + 1.5, frame.size.width - 3.0, frame.size.height - 4.0);
    NSBezierPath *bezelPath = [NSBezierPath bezierPath];
    [bezelPath moveToPoint:NSMakePoint(NSMinX(bezelRect) + 10.0, NSMinY(bezelRect))];
    [bezelPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(bezelRect) - 3.0, NSMinY(bezelRect) + 3.0) radius:3.0 startAngle:270.0 endAngle:360.0];
    [bezelPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(bezelRect) - 3.0, NSMaxY(bezelRect) - 3.0) radius:3.0 startAngle:0.0 endAngle:90.0];
    [bezelPath lineToPoint:NSMakePoint(NSMinX(bezelRect) + 10.0, NSMaxY(bezelRect))];
    [bezelPath curveToPoint:NSMakePoint(NSMinX(bezelRect), NSMidY(bezelRect)) controlPoint1:NSMakePoint(NSMinX(bezelRect) + 5.0, NSMaxY(bezelRect)) controlPoint2:NSMakePoint(NSMinX(bezelRect), NSMidY(bezelRect))];
    [bezelPath curveToPoint:NSMakePoint(NSMinX(bezelRect) + 10.0, NSMinY(bezelRect)) controlPoint1:NSMakePoint(NSMinX(bezelRect), NSMidY(bezelRect)) controlPoint2:NSMakePoint(NSMinX(bezelRect) + 5.0, NSMinY(bezelRect))];
    [bezelPath closePath];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    if ([self isHighlighted]) {
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.1]
                                                             endingColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.2]];
        [gradient drawInBezierPath:bezelPath angle:-90.0];
    }
    else {
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.0]
                                                             endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.7]];
        [gradient drawInBezierPath:bezelPath angle:-90.0];
    }
    
    [bezelPath addClip];
    
    if ([self isHighlighted]) {
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.0]
                                                             endingColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.4]];
        [gradient drawInRect:NSMakeRect(bezelRect.origin.x, bezelRect.origin.y, bezelRect.size.width, floor(bezelRect.size.height / 4.0)) angle:-90.0];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        [shadow setShadowBlurRadius:1.0];
        [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.5]];
        [shadow setShadowOffset:NSZeroSize];
        [shadow set];
        
        [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
        [bezelPath stroke];
    }
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
    [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
    [bezelPath stroke];
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
    NSSize cellSize = [super cellSizeForBounds:aRect];
    cellSize.width += 5.0;
    return cellSize;
}

- (NSRect)imageRectForBounds:(NSRect)theRect {
    NSRect imageRect = [super imageRectForBounds:theRect];
    imageRect.origin.x += 5.0;
    imageRect.size.width -= 5.0;
    return imageRect;
}

- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleRect = [super titleRectForBounds:theRect];
    titleRect.origin.x += 5.0;
    titleRect.size.width -= 5.0;
    return titleRect;
}

@end
