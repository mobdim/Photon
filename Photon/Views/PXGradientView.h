//
//  PXGradientView.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXGradientView : NSView

@property (copy) NSGradient *gradient;
@property (copy) NSGradient *inactiveGradient;

@property BOOL hasTopBorder;
@property BOOL hasBottomBorder;

@property (copy) NSColor *topBorderColor;
@property (copy) NSColor *bottomBorderColor;

@property (copy) NSColor *inactiveTopBorderColor;
@property (copy) NSColor *inactiveBottomBorderColor;

@property CGFloat topInsetAlpha;
@property CGFloat bottomInsetAlpha;

@end
