//
//  PXGradientView.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXGradientView : NSView

@property (copy) NSGradient *gradient;
@property (copy) NSGradient *inactiveGradient;

@property (assign) BOOL hasTopBorder;
@property (assign) BOOL hasBottomBorder;

@property (copy) NSColor *topBorderColor;
@property (copy) NSColor *bottomBorderColor;

@property (copy) NSColor *inactiveTopBorderColor;
@property (copy) NSColor *inactiveBottomBorderColor;

@property (assign) CGFloat topInsetAlpha;
@property (assign) CGFloat bottomInsetAlpha;

@end
