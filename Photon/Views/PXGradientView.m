//
//  PXGradientView.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXGradientView.h"
#import "NSObject+PhotonAdditions.h"


@implementation PXGradientView

@synthesize gradient;
@synthesize inactiveGradient;
@synthesize hasTopBorder;
@synthesize hasBottomBorder;
@synthesize topBorderColor;
@synthesize bottomBorderColor;
@synthesize inactiveTopBorderColor;
@synthesize inactiveBottomBorderColor;
@synthesize topInsetAlpha;
@synthesize bottomInsetAlpha;

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]
                                                      endingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]];
        
        self.hasTopBorder = YES;
        self.hasBottomBorder = YES;
        
        self.topBorderColor = [NSColor colorWithCalibratedWhite:0.6 alpha:1.0];
        self.bottomBorderColor = [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];
        
        [self addObserver:self forKeyPaths:[NSSet setWithObjects:@"gradient", @"inactiveGradient", @"hasTopBorder", @"hasBottomBorder", @"topBorderColor", @"bottomBorderColor", @"inactiveTopBorderColor", @"inactiveBottomBorderColor", @"topInsetAlpha", @"bottomInsetAlpha", nil] options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPaths:[NSSet setWithObjects:@"gradient", @"inactiveGradient", @"hasTopBorder", @"hasBottomBorder", @"topBorderColor", @"bottomBorderColor", @"inactiveTopBorderColor", @"inactiveBottomBorderColor", @"topInsetAlpha", @"bottomInsetAlpha", nil]];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
        [self setNeedsDisplay:YES];
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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

- (void)drawRect:(NSRect)dirtyRect {
    if (![[self window] isMainWindow] && inactiveGradient != nil) {
        [inactiveGradient drawInRect:[self bounds] angle:-90.0];
    }
    else {
        [gradient drawInRect:[self bounds] angle:-90.0];
    }
    
    if (hasTopBorder) {
        if (![[self window] isMainWindow] && inactiveTopBorderColor != nil) {
            [inactiveTopBorderColor set];
        }
        else {
            [topBorderColor set];
        }
        [NSBezierPath strokeLineFromPoint:NSMakePoint(0.0, [self bounds].size.height - 0.5) toPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height - 0.5)];
    }
    
    if (hasBottomBorder) {
        if (![[self window] isMainWindow] && inactiveBottomBorderColor != nil) {
            [inactiveBottomBorderColor set];
        }
        else {
            [bottomBorderColor set];
        }
        [NSBezierPath strokeLineFromPoint:NSMakePoint(0.0, 0.5) toPoint:NSMakePoint([self bounds].size.width, 0.5)];
    }
    
    [[NSColor colorWithCalibratedWhite:1.0 alpha:topInsetAlpha] set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(0.0, [self bounds].size.height - (hasTopBorder ? 1.5 : 0.5)) toPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height - (hasTopBorder ? 1.5 : 0.5))];
    
    [[NSColor colorWithCalibratedWhite:1.0 alpha:bottomInsetAlpha] set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(0.0, (hasBottomBorder ? 1.5 : 0.5)) toPoint:NSMakePoint([self bounds].size.width, (hasBottomBorder ? 1.5 : 0.5))];
}

@end
