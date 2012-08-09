//
//  PXAnchoredButtonBar.m
//  Schoolhouse
//
//  Created by Logan Collins on 12/27/10.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXAnchoredButtonBar.h"


@implementation PXAnchoredButtonBar

- (void)drawRect:(NSRect)dirtyRect {
    NSColor *topColor = [NSColor colorWithCalibratedWhite:(253.0f / 255.0f) alpha:1.0];
    NSColor *middleTopColor = [NSColor colorWithCalibratedWhite:(242.0f / 255.0f) alpha:1.0];
    NSColor *middleBottomColor = [NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1.0];
    NSColor *bottomColor = [NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1.0];
    
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:
                             topColor, (CGFloat)0.0,
                             middleTopColor, (CGFloat)0.45454,
                             middleBottomColor, (CGFloat)0.45454,
                             bottomColor, (CGFloat)1.0,
                             nil];
    
    // Draw gradient
    NSRect gradientRect = NSInsetRect([self bounds], 0.0, 1.0);
    [gradient drawInRect:gradientRect angle:-90.0];
    
    // Draw borders
    [[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
    [NSBezierPath strokeRect:NSInsetRect([self bounds], 0.5, 0.5)];
}

@end
