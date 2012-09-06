//
//  PXSwitch.m
//  Photon
//
//  Created by Logan Collins on 3/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXSwitch.h"
#include <QuartzCore/QuartzCore.h>


@interface PXSwitchBackgroundLayer : CALayer

@property (getter=isEnabled) BOOL enabled;
@property NSColor *onTintColor;

@end


@implementation PXSwitchBackgroundLayer {
    NSGradient *_gradient;
	BOOL _enabled;
	NSColor *_onTintColor;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setNeedsDisplayOnBoundsChange:YES];
		
        _gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.0]
												  endingColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]];
        
        // Resolution independence
        const CGFloat contentScale = [[NSScreen mainScreen] backingScaleFactor];
        [self setContentsScale:contentScale];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
	[NSGraphicsContext saveGraphicsState];
    
	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
	[NSGraphicsContext setCurrentContext:context];
    
    NSRect bounds = [self bounds];
    const CGFloat width = NSWidth(bounds);
    const CGFloat height = NSHeight(bounds);
    
    // Off colored part
    [[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] set];
    NSRectFill(bounds);
    
    // On colored part
    NSRect onColoredRect = NSMakeRect(0.0, 0.0, width / 2.0, height);
    [[self onTintColor] set];
    NSRectFill(onColoredRect);
    
    // Disabled style
    if (![self isEnabled]) {
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.85] set];
        [[NSBezierPath bezierPathWithRect:bounds] fill];
    }
    
    // Gradient
    [_gradient drawInRect:bounds angle:90];
    
    // Inner shadow
    [context saveGraphicsState];
    [context setCompositingOperation:NSCompositePlusDarker];
    
    CGFloat radius = 2.0;
    CGRect outterRect = CGRectInset(bounds, -1.0, -1.0);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:outterRect xRadius:radius yRadius:radius];
    
    [[NSColor redColor] setStroke];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:(self.enabled ? 0.3 : 0.1)]];
    [shadow setShadowBlurRadius:3.0];
    [shadow setShadowOffset:NSMakeSize(0.0, -3.0)];
    [shadow set];
    
    [path stroke];
    
    [context restoreGraphicsState];  
    
	[NSGraphicsContext restoreGraphicsState];
}

- (BOOL)isEnabled {
	return _enabled;
}

- (void)setEnabled:(BOOL)enabled {
    [self willChangeValueForKey:@"enabled"];
    _enabled = enabled;
    [self didChangeValueForKey:@"enabled"];   
    
    CGColorRef grayColor = CGColorCreateGenericGray(enabled ? 0.38 : 0.58, 1.0);
    [self setBorderColor:grayColor];
    CGColorRelease(grayColor);
    
    [self setNeedsDisplay];
}

- (NSColor *)onTintColor {
	return _onTintColor;
}

- (void)setOnTintColor:(NSColor *)onTintColor {
    [self willChangeValueForKey:@"onTintColor"];
    _onTintColor = onTintColor;
    [self didChangeValueForKey:@"onTintColor"];
    [self setNeedsDisplay];
}

@end


@interface PXSwitchKnobLayer : CALayer

@property (getter=isEnabled) BOOL enabled;
@property (getter=isPressed) BOOL pressed;

@end


@implementation PXSwitchKnobLayer {
    NSGradient *_gradient;
	BOOL _enabled;
	BOOL _pressed;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setNeedsDisplayOnBoundsChange:YES];
        [self setEnabled:YES];
        
        // Resolution independence
        const CGFloat contentScale = [[NSScreen mainScreen] backingScaleFactor];
        [self setContentsScale:contentScale];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
	[NSGraphicsContext saveGraphicsState];
    
	NSGraphicsContext * context = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
	[NSGraphicsContext setCurrentContext:context];
    
    CGFloat cornerRadius = [self cornerRadius];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerRadius yRadius:cornerRadius];
    [_gradient drawInBezierPath:path angle:([self isPressed] ? 270.0 : 90.0)];
    
	[NSGraphicsContext restoreGraphicsState];  
}

- (BOOL)isEnabled {
	return _enabled;
}

- (void)setEnabled:(BOOL)enabled {
    [self willChangeValueForKey:@"enabled"];
    _enabled = enabled;
	
    NSColor *reflectionStartColor = (enabled ? [NSColor colorWithCalibratedWhite:0.89 alpha:1.0] : [NSColor colorWithCalibratedWhite:0.95 alpha:1.0]);
    NSColor *reflectionEndColor = (enabled ? [NSColor colorWithCalibratedWhite:0.95 alpha:1.0] : [NSColor colorWithCalibratedWhite:0.98 alpha:1.0]);
    _gradient = [[NSGradient alloc] initWithStartingColor:reflectionStartColor endingColor:reflectionEndColor];
	
    [self didChangeValueForKey:@"enabled"];
    [self setNeedsDisplay];
}

- (BOOL)isPressed {
	return _pressed;
}

- (void)setPressed:(BOOL)pressed {
    [self willChangeValueForKey:@"pressed"];
	_pressed = pressed;
    [self didChangeValueForKey:@"pressed"];
    [self setNeedsDisplay];
}

@end


@interface PXSwitch ()

- (void)px_initLayersWithFrame:(NSRect)frame;

@end


@implementation PXSwitch {
    PXSwitchBackgroundLayer *_backgroundLayer;
    PXSwitchKnobLayer *_knobLayer;
    CALayer *_shadowLayer;
    CALayer *_contentLayer;
	BOOL _enabled;
	BOOL _on;
}

@synthesize onTintColor=_onTintColor;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self px_initLayersWithFrame:frame];
        
        // Default tint color
        [self setOnTintColor:[NSColor colorWithCalibratedHue:(210.0/360.0) saturation:1.0 brightness:1.0 alpha:1.0]];
        
        [self setEnabled:YES];
        [self setOn:NO animated:NO];
    }
    return self;
}

- (void)px_initLayersWithFrame:(NSRect)frame {
    // Core animation layers setup
    [self setWantsLayer:YES];
    CALayer * rootLayer = [CALayer layer];
    [rootLayer setMasksToBounds:YES];
    [self setLayer:rootLayer];

    CGColorRef grayColor = CGColorCreateGenericGray(0.38, 1.0);
    CGColorRef whiteColor = CGColorCreateGenericRGB(1.0, 1.0, 1.0, 0.8);
        
    // White shadow layer
    CGRect shadowLayerFrame = CGRectMake(0.0, 1.0, NSWidth(frame), NSHeight(frame) - 1.0);
    _shadowLayer = [CALayer layer];
    [_shadowLayer setBackgroundColor:whiteColor];
    [_shadowLayer setCornerRadius:round((NSHeight(frame) - 1.0) / 2.0)];
    [_shadowLayer setFrame:shadowLayerFrame];
    [rootLayer addSublayer:_shadowLayer];
    
    // Content layer
    _contentLayer = [CALayer layer];
    CAConstraintLayoutManager *layoutManager = [CAConstraintLayoutManager layoutManager];
    [_contentLayer setLayoutManager:layoutManager];
    CGRect contentLayerFrame = CGRectMake(0.0, 2.0, NSWidth(frame), NSHeight(frame) - 2.0);
    [_contentLayer setFrame:contentLayerFrame];
    [_contentLayer setMasksToBounds:YES];
    [_contentLayer setBorderWidth:1.0];
    [_contentLayer setBorderColor:grayColor];
    [_contentLayer setCornerRadius:round((NSHeight(frame) - 2.0) / 2.0)];
    [rootLayer addSublayer:_contentLayer];
    
    // Background layer
    CGRect backgroundLayerBounds = CGRectMake(0.0, 0.0, NSWidth(frame) * 2.0, NSHeight(frame) - 2.0);
    _backgroundLayer = [PXSwitchBackgroundLayer layer];
    [_backgroundLayer setName:@"backgroundLayer"];
    [_backgroundLayer setEnabled:[self isEnabled]];
    [_backgroundLayer bind:@"enabled" toObject:self withKeyPath:@"enabled" options:nil];
    [_backgroundLayer bind:@"onTintColor" toObject:self withKeyPath:@"onTintColor" options:nil];
    [_backgroundLayer setDelegate:self];
    [_backgroundLayer setBounds:backgroundLayerBounds];
    [_contentLayer addSublayer:_backgroundLayer];
    
    // Knob
    _knobLayer = [PXSwitchKnobLayer layer];
    [_knobLayer setName:@"knobLayer"];
    const CGFloat knobSizeRatio = 1.0;
    const CGFloat knobHeight = NSHeight(frame) - 2.0;
    CGRect knobRect = CGRectIntegral(CGRectMake(0.0, 0.0, knobSizeRatio * knobHeight, knobHeight - 2.0));
    [_knobLayer setBounds:knobRect];
    NSMutableDictionary *actions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									[NSNull null], @"onOrderIn",
									[NSNull null], @"onOrderOut",
									[NSNull null], @"sublayers",
									[NSNull null], @"contents",
									[NSNull null], @"bounds",
									nil];
    [_knobLayer setActions:actions];
    [_knobLayer setCornerRadius:round(knobHeight / 2.0)];
    [_knobLayer setShadowRadius:3.0];
    [_knobLayer setShadowOpacity:1.0];
    [_contentLayer addSublayer:_knobLayer];
    
    // Contraints
    [_knobLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY]];
    [_backgroundLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY]];
    
    CGColorRelease(grayColor);
    CGColorRelease(whiteColor);
}

- (id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    CAAnimation *positionTransition = [CAAnimation new];
    [positionTransition setDuration:0.0f];
    return positionTransition;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (![self isEnabled]) {
        return;
    }
    
    BOOL dragging = YES;
    BOOL wasDragging = NO;
    
    const CGFloat width = CGRectGetWidth([_knobLayer bounds]);
    const CGFloat height = CGRectGetHeight([_knobLayer bounds]);
    const CGFloat y = [_knobLayer frame].origin.y;
    NSPoint startingPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if ([_knobLayer hitTest:NSPointToCGPoint(startingPoint)]) {
        [_knobLayer setPressed:YES];
    }
    
    CGFloat deltaX = [_knobLayer convertPoint:NSPointToCGPoint(startingPoint) fromLayer:[self layer]].x;
    while (dragging) {
        theEvent = [[self window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        NSPoint currentPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        CGFloat x = currentPoint.x - deltaX;
		switch ([theEvent type]) {
			case NSLeftMouseDown:
				break;
				
            case NSLeftMouseUp:
                if(wasDragging) {
                    // The user was dragging, let's see where the knob ended and set the final state accordingly
                    if(CGRectGetMidX([_knobLayer frame]) > CGRectGetWidth([self frame]) / 2.0) {
                        [self setOn:YES];
                    }
                    else {
                        [self setOn:NO];
                    }
                }
                else {
                    // The knob wasn't dragged, just switch to the opposite state with animation
                    [self setOn:![self isOn]];
                }
                dragging = NO;
                [_knobLayer setPressed:NO];
                break;
				
            case NSLeftMouseDragged: {
                if (![_knobLayer isPressed]) {
                    dragging = NO;
                    break;
                }
                wasDragging = YES;
                
                // Keep the knob within the slider's bounds
                x = fmax(x, 0.0);
                x = fmin(CGRectGetWidth([self frame]) - width, x);
                
                // Move the knob and the background layers
                [_knobLayer setDelegate:self];
                [_backgroundLayer setDelegate:self];
                [_knobLayer setFrame:CGRectMake(x, y, width, height)];
                [_backgroundLayer setPosition:[_knobLayer position]];
                [_knobLayer setDelegate:nil];
                [_backgroundLayer setDelegate:nil];
                break;
            }
            default: {
                break;
			}
        }
    }
}

- (BOOL)isEnabled {
	return _enabled;
}

- (void)setEnabled:(BOOL)enabled {
    [self willChangeValueForKey:@"enabled"];
    _enabled = enabled;
    [self didChangeValueForKey:@"enabled"];

    [_knobLayer setEnabled:enabled];
    [_backgroundLayer setEnabled:enabled];
    
    CGColorRef grayColor = CGColorCreateGenericGray(enabled ? 0.38 : 0.68, 1.0);
    [_contentLayer setBorderColor:grayColor];
    CGColorRelease(grayColor);
    
    [_knobLayer setShadowOpacity:(enabled ? 1.0 : 0.3)];
}

- (BOOL)isOn {
	return _on;
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:YES];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    if (!animated) {
        [_knobLayer setDelegate:self];  
        [_backgroundLayer setDelegate:self];
    }
	
    const CGFloat width = CGRectGetWidth([_knobLayer bounds]);
    const CGFloat height = CGRectGetHeight([_knobLayer bounds]);
    const CGFloat y = [_knobLayer frame].origin.y;
    const CGFloat x = (on ? CGRectGetWidth([self frame]) - width : 0.0);
	
    [_knobLayer setFrame:CGRectMake(x, y, width, height)];
    [_backgroundLayer setPosition:[_knobLayer position]];
    [_knobLayer setDelegate:nil];
    [_backgroundLayer setDelegate:nil];

    [self willChangeValueForKey:@"on"];
    _on = on;
    [self didChangeValueForKey:@"on"];
}

- (NSSize)intrinsicContentSize {
    return NSMakeSize(36.0, 16.0);
}

@end
