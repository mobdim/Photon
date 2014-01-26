//
//  PXKeyCombinationField.m
//  LCToolkit
//
//  Created by Logan Collins on 7/19/09.
//  Copyright 2009 Logan Collins. All rights reserved.
//

#import "PXKeyCombinationField.h"

#import "PXKeyCombination.h"
#import <Carbon/Carbon.h>


@implementation PXKeyCombinationField {
    PXKeyModifierFlags _allowedModifierFlags;
    PXKeyModifierFlags _requiredModifierFlags;
    
    PXKeyCombinationValidator *_validator;
	NSSet *_cancelCharacterSet;
    BOOL _recording;
	PXKeyModifierFlags _recordingModifierFlags;
    void *_hotKeyModeToken;
    
	NSTrackingArea *_removeTrackingArea;
	NSTrackingArea *_snapbackTrackingArea;
	BOOL _mouseInsideTrackingArea;
	BOOL _mouseDown;
}

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self) {
        // Initialize the validator object
        _validator = [[PXKeyCombinationValidator alloc] init];
        
        // Allow all modifier keys by default, nothing is required
        _allowedModifierFlags = (PXKeyModifierAlphaShift|PXKeyModifierAlternate|PXKeyModifierCommand|PXKeyModifierControl|PXKeyModifierShift);
        
        // These keys will cancel the recoding mode if not pressed with any modifier
        _cancelCharacterSet = [NSSet setWithObjects:
                               @53,     // Escape
                               @51,     // Backspace
                               @117,    // Delete
                               nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemColorsDidChange:) name:NSSystemColorsDidChangeNotification object:nil];
        
        [self updateTrackingAreas];
        
        [self addObserver:self forKeyPath:@"keyCombination" options:(NSKeyValueObservingOptionNew) context:nil];
	}
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSSystemColorsDidChangeNotification object:nil];
    [self removeObserver:self forKeyPath:@"keyCombination"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"keyCombination"]) {
		if ([self.delegate respondsToSelector:@selector(keyCombinationFieldDidChange:)]) {
			[self.delegate keyCombinationFieldDidChange:self];
        }
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)systemColorsDidChange:(NSNotification *)notification {
	
}


#pragma mark -
#pragma mark Accessors

- (PXKeyModifierFlags)allowedModifierFlags {
	return _allowedModifierFlags;
}

- (void)setAllowedModifierFlags:(PXKeyModifierFlags)allowedModifierFlags {
	_allowedModifierFlags = allowedModifierFlags;
	
	// Filter new flags and change keycombo if not recording
	if (_recording) {
        PXKeyModifierFlags flags = (PXKeyModifierFlags)[[[NSApplication sharedApplication] currentEvent] modifierFlags];
		_recordingModifierFlags = [self filteredModifierFlags:flags];
	}
	else {
        CGKeyCode keyCode = [[self keyCombination] keyCode];
        PXKeyModifierFlags flags = [[self keyCombination] modifierFlags];
		PXKeyCombination *combination = [[PXKeyCombination alloc] initWithKeyCode:keyCode modifierFlags:[self filteredModifierFlags:flags]];
		[self setKeyCombination:combination];
	}
}

- (PXKeyModifierFlags)requiredModifierFlags {
	return _requiredModifierFlags;
}

- (void)setRequiredModifierFlags:(PXKeyModifierFlags)requiredModifierFlags {
	_requiredModifierFlags = requiredModifierFlags;
	
	// Filter new flags and change keycombo if not recording
	if (_recording) {
        PXKeyModifierFlags flags = (PXKeyModifierFlags)[[[NSApplication sharedApplication] currentEvent] modifierFlags];
		_recordingModifierFlags = [self filteredModifierFlags:flags];
	}
	else {
        CGKeyCode keyCode = [[self keyCombination] keyCode];
        PXKeyModifierFlags flags = [[self keyCombination] modifierFlags];
		PXKeyCombination *combination = [[PXKeyCombination alloc] initWithKeyCode:keyCode modifierFlags:[self filteredModifierFlags:flags]];
		[self setKeyCombination:combination];
	}
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect {
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect([self bounds], 0.5, 0.5) xRadius:3.0 yRadius:3.0];
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    // Background
    [backgroundPath addClip];
    NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]
                                                                   endingColor:[NSColor colorWithCalibratedWhite:0.85 alpha:1.0]];
    [backgroundGradient drawInBezierPath:backgroundPath angle:-90.0];
    
    
    // Separator
    NSRect buttonRect = [self removeButtonRectForFrame:[self bounds]];
    if (_mouseInsideTrackingArea && _mouseDown) {
        [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
    }
    else {
        [[NSColor colorWithCalibratedWhite:0.7 alpha:1.0] set];
    }
    [NSBezierPath fillRect:NSMakeRect(buttonRect.origin.x - 1.0, 0.0, 1.0, [self bounds].size.height)];
    
    NSRect deleteRect = NSMakeRect(buttonRect.origin.x + round((buttonRect.size.width - 8.0) / 2.0), buttonRect.origin.y + round((buttonRect.size.height - 6.0) / 2.0), 6.0, 6.0);
    NSBezierPath *deletePath = [NSBezierPath bezierPath];
    [deletePath moveToPoint:NSMakePoint(NSMinX(deleteRect), NSMinY(deleteRect))];
    [deletePath lineToPoint:NSMakePoint(NSMaxX(deleteRect), NSMaxY(deleteRect))];
    [deletePath moveToPoint:NSMakePoint(NSMinX(deleteRect), NSMaxY(deleteRect))];
    [deletePath lineToPoint:NSMakePoint(NSMaxX(deleteRect), NSMinY(deleteRect))];
    [deletePath setLineCapStyle:NSRoundLineCapStyle];
    [deletePath setLineWidth:2.0];
    
    if (_mouseInsideTrackingArea && _mouseDown) {
        [[NSColor colorWithCalibratedWhite:0.0 alpha:0.1] set];
        [NSBezierPath fillRect:buttonRect];
        
        [[NSColor colorWithCalibratedWhite:0.5 alpha:1.0] set];
        [deletePath stroke];
    }
    else {
        [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
        [deletePath stroke];
    }
    
    
    // Shadow and Stroke
    NSShadow *backgroundShadow = [[NSShadow alloc] init];
    [backgroundShadow setShadowBlurRadius:3.0];
    [backgroundShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]];
    [backgroundShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
    [backgroundShadow set];
    
    [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
    [backgroundPath stroke];
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
    
    [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
    [backgroundPath stroke];
    
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    [backgroundPath addClip];
    [[NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, buttonRect.origin.x - 1.0, [self bounds].size.height)] addClip];
    
    if (self.keyCombination != nil || _recording) {
        // Modifiers
        PXKeyModifierFlags flags = (_recording ? _recordingModifierFlags : [self.keyCombination modifierFlags]);
        if (_recording && flags == 0) {
            NSShadow *textShadow = [[NSShadow alloc] init];
            [textShadow setShadowBlurRadius:0.0];
            [textShadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.4]];
            [textShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
            
            NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSFont systemFontOfSize:11.0], NSFontAttributeName,
                                            [NSColor colorWithCalibratedWhite:0.4 alpha:1.0], NSForegroundColorAttributeName,
                                            textShadow, NSShadowAttributeName,
                                            nil];
            
            NSString *text = NSLocalizedStringFromTable(@"Type a new shortcut", @"KeyCombinations", nil);
            NSSize textSize = [text sizeWithAttributes:textAttributes];
            [text drawInRect:NSMakeRect(10.0, round(([self bounds].size.height - textSize.height) / 2.0), textSize.width, textSize.height) withAttributes:textAttributes];
        }
        else {
            CGFloat keyInset = 3.0;
            CGFloat keyWidth = 28.0;
            CGFloat modifierWidth = 28.0;
            CGFloat keyHeight = [self bounds].size.height - (keyInset * 2.0);
            CGFloat keyRadius = 2.0;
            
            NSGradient *keyGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
                                                                    endingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]];
            NSColor *keyStrokeColor = [NSColor colorWithCalibratedWhite:0.6 alpha:1.0];
            
            NSShadow *keyShadow = [[NSShadow alloc] init];
            [keyShadow setShadowBlurRadius:2.0];
            [keyShadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.25]];
            [keyShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
            
            NSDictionary *keyTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSFont systemFontOfSize:12.0], NSFontAttributeName,
                                               [NSColor colorWithCalibratedWhite:0.2 alpha:1.0], NSForegroundColorAttributeName,
                                               nil];
            
            CGFloat xPos = keyInset;
            
            if (flags & PXKeyModifierControl) {
                // Key
                NSRect keyRect = NSMakeRect(xPos, keyInset, modifierWidth, keyHeight);
                NSBezierPath *keyPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(keyRect, 0.5, 0.5) xRadius:keyRadius yRadius:keyRadius];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyShadow set];
                [[NSColor whiteColor] set];
                [keyPath fill];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyPath addClip];
                [keyGradient drawInBezierPath:keyPath angle:-90.0];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [keyStrokeColor set];
                [keyPath stroke];
                
                // Text
                NSString *text = [PXKeyCombination stringForKeyModifierFlags:(PXKeyModifierControl)];
                NSSize textSize = [text sizeWithAttributes:keyTextAttributes];
                NSRect textRect = NSMakeRect(xPos + round((modifierWidth - textSize.width) / 2.0), keyInset + round((keyHeight - textSize.height) / 2.0), textSize.width, textSize.height);
                [text drawInRect:textRect withAttributes:keyTextAttributes];
                
                xPos += keyInset + modifierWidth;
            }
            
            if (flags & PXKeyModifierAlternate) {
                // Key
                NSRect keyRect = NSMakeRect(xPos, keyInset, modifierWidth, keyHeight);
                NSBezierPath *keyPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(keyRect, 0.5, 0.5) xRadius:keyRadius yRadius:keyRadius];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyShadow set];
                [[NSColor whiteColor] set];
                [keyPath fill];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyPath addClip];
                [keyGradient drawInBezierPath:keyPath angle:-90.0];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [keyStrokeColor set];
                [keyPath stroke];
                
                // Text
                NSString *text = [PXKeyCombination stringForKeyModifierFlags:(PXKeyModifierAlternate)];
                NSSize textSize = [text sizeWithAttributes:keyTextAttributes];
                NSRect textRect = NSMakeRect(xPos + round((modifierWidth - textSize.width) / 2.0), keyInset + round((keyHeight - textSize.height) / 2.0), textSize.width, textSize.height);
                [text drawInRect:textRect withAttributes:keyTextAttributes];
                
                xPos += keyInset + modifierWidth;
            }
            
            if (flags & PXKeyModifierShift) {
                // Key
                NSRect keyRect = NSMakeRect(xPos, keyInset, modifierWidth, keyHeight);
                NSBezierPath *keyPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(keyRect, 0.5, 0.5) xRadius:keyRadius yRadius:keyRadius];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyShadow set];
                [[NSColor whiteColor] set];
                [keyPath fill];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyPath addClip];
                [keyGradient drawInBezierPath:keyPath angle:-90.0];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [keyStrokeColor set];
                [keyPath stroke];
                
                // Text
                NSString *text = [PXKeyCombination stringForKeyModifierFlags:(PXKeyModifierShift)];
                NSSize textSize = [text sizeWithAttributes:keyTextAttributes];
                NSRect textRect = NSMakeRect(xPos + round((modifierWidth - textSize.width) / 2.0), keyInset + round((keyHeight - textSize.height) / 2.0), textSize.width, textSize.height);
                [text drawInRect:textRect withAttributes:keyTextAttributes];
                
                xPos += keyInset + modifierWidth;
            }
            
            if (flags & PXKeyModifierCommand) {
                // Key
                NSRect keyRect = NSMakeRect(xPos, keyInset, modifierWidth, keyHeight);
                NSBezierPath *keyPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(keyRect, 0.5, 0.5) xRadius:keyRadius yRadius:keyRadius];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyShadow set];
                [[NSColor whiteColor] set];
                [keyPath fill];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyPath addClip];
                [keyGradient drawInBezierPath:keyPath angle:-90.0];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [keyStrokeColor set];
                [keyPath stroke];
                
                // Text
                NSString *text = [PXKeyCombination stringForKeyModifierFlags:(PXKeyModifierCommand)];
                NSSize textSize = [text sizeWithAttributes:keyTextAttributes];
                NSRect textRect = NSMakeRect(xPos + round((modifierWidth - textSize.width) / 2.0), keyInset + round((keyHeight - textSize.height) / 2.0), textSize.width, textSize.height);
                [text drawInRect:textRect withAttributes:keyTextAttributes];
                
                xPos += keyInset + modifierWidth;
            }
            
            if (!_recording) {
                NSString *text = [PXKeyCombination stringForKeyCode:self.keyCombination.keyCode];
                NSSize textSize = [text sizeWithAttributes:keyTextAttributes];
                
                CGFloat width = keyWidth;
                width = MAX(width, textSize.width + 20.0);
                
                // Key
                NSRect keyRect = NSMakeRect(xPos, keyInset, width, keyHeight);
                NSBezierPath *keyPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(keyRect, 0.5, 0.5) xRadius:keyRadius yRadius:keyRadius];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyShadow set];
                [[NSColor whiteColor] set];
                [keyPath fill];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [[NSGraphicsContext currentContext] saveGraphicsState];
                [keyPath addClip];
                [keyGradient drawInBezierPath:keyPath angle:-90.0];
                [[NSGraphicsContext currentContext] restoreGraphicsState];
                
                [keyStrokeColor set];
                [keyPath stroke];
                
                // Text
                NSRect textRect = NSMakeRect(xPos + round((width - textSize.width) / 2.0), keyInset + round((keyHeight - textSize.height) / 2.0), textSize.width, textSize.height);
                [text drawInRect:textRect withAttributes:keyTextAttributes];
                
                xPos += keyInset + keyWidth;
            }
        }
    }
    else {
        NSShadow *textShadow = [[NSShadow alloc] init];
        [textShadow setShadowBlurRadius:0.0];
        [textShadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.4]];
        [textShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSFont systemFontOfSize:11.0], NSFontAttributeName,
                                        [NSColor colorWithCalibratedWhite:0.4 alpha:1.0], NSForegroundColorAttributeName,
                                        textShadow, NSShadowAttributeName,
                                        nil];
        
        NSString *text = NSLocalizedStringFromTable(@"Type a new shortcut", @"KeyCombinations", nil);
        NSSize textSize = [text sizeWithAttributes:textAttributes];
        [text drawInRect:NSMakeRect(10.0, round(([self bounds].size.height - textSize.height) / 2.0), textSize.width, textSize.height) withAttributes:textAttributes];
    }
    
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
    
    if (_mouseInsideTrackingArea) {
        NSRect baseRect = NSInsetRect(NSMakeRect(0.0, 0.0, buttonRect.origin.x - 1.0, [self bounds].size.height), 3.5, 3.5);
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSFont systemFontOfSize:11.0], NSFontAttributeName,
                                        [NSColor colorWithCalibratedWhite:1.0 alpha:1.0], NSForegroundColorAttributeName,
                                        nil];
        
        if (_recording && self.keyCombination != nil) {
            NSString *text = NSLocalizedStringFromTable(@"Restore previous shortcut", @"KeyCombinations", nil);
            NSSize textSize = [text sizeWithAttributes:textAttributes];
            
            NSRect pathRect = baseRect;
            pathRect.size.width = MIN(textSize.width + 20.0, pathRect.size.width);
            
            NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:pathRect xRadius:2.0 yRadius:2.0];
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] set];
            [backgroundPath fill];
            
            [[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] set];
            [backgroundPath stroke];
            
            [text drawInRect:NSMakeRect(pathRect.origin.x + 10.0, round(([self bounds].size.height - textSize.height) / 2.0), textSize.width, textSize.height) withAttributes:textAttributes];
        }
        else if (!_recording && self.keyCombination != nil) {
            NSString *text = NSLocalizedStringFromTable(@"Clear current shortcut", @"KeyCombinations", nil);
            NSSize textSize = [text sizeWithAttributes:textAttributes];
            
            NSRect pathRect = baseRect;
            pathRect.size.width = MIN(textSize.width + 20.0, pathRect.size.width);
            
            NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:pathRect xRadius:2.0 yRadius:2.0];
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] set];
            [backgroundPath fill];
            
            [[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] set];
            [backgroundPath stroke];
            
            [text drawInRect:NSMakeRect(pathRect.origin.x + 10.0, round(([self bounds].size.height - textSize.height) / 2.0), textSize.width, textSize.height) withAttributes:textAttributes];
        }
        else if (_recording && self.keyCombination == nil) {
            NSString *text = NSLocalizedStringFromTable(@"Cancel", @"KeyCombinations", nil);
            NSSize textSize = [text sizeWithAttributes:textAttributes];
            
            NSRect pathRect = baseRect;
            pathRect.size.width = MIN(textSize.width + 20.0, pathRect.size.width);
            
            NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:pathRect xRadius:2.0 yRadius:2.0];
            [[NSColor colorWithCalibratedWhite:0.0 alpha:0.8] set];
            [backgroundPath fill];
            
            [[NSColor colorWithCalibratedWhite:0.0 alpha:1.0] set];
            [backgroundPath stroke];
            
            [text drawInRect:NSMakeRect(pathRect.origin.x + 10.0, round(([self bounds].size.height - textSize.height) / 2.0), textSize.width, textSize.height) withAttributes:textAttributes];
        }
    }
    
    
    // Recording
    if ([[self window] firstResponder] == self && _recording) {
        NSSetFocusRingStyle(NSFocusRingOnly);
        [backgroundPath fill];
    }
}

- (NSRect)removeButtonRectForFrame:(NSRect)cellFrame {
	NSRect removeButtonRect = NSMakeRect([self bounds].size.width - 20.0, 0.0, 20.0, [self bounds].size.height);
    
//	NSImage *removeImage = [NSImage imageNamed:@"PXKeyCombinationRemove"];
//	removeButtonRect.origin = NSMakePoint(NSMaxX(cellFrame) - [removeImage size].width - 4.0, (NSMaxY(cellFrame) - [removeImage size].height) / 2.0);
//	removeButtonRect.size = [removeImage size];
	
	return removeButtonRect;
}


#pragma mark -
#pragma mark Responder

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
	return YES;
}

- (BOOL)becomeFirstResponder  {
    [self updateTrackingAreas];
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)resignFirstResponder {
    if (_recording) {
        [self endRecording];
    }
    [self updateTrackingAreas];
    [self setNeedsDisplay:YES];
    return YES;
}

- (void)updateTrackingAreas {
	NSPoint mouseLocation = [self convertPoint:[[[NSApplication sharedApplication] currentEvent] locationInWindow] fromView:nil];
	
	if (_removeTrackingArea != nil) {
		[self removeTrackingArea:_removeTrackingArea];
    }
    
	if (_snapbackTrackingArea != nil) {
		[self removeTrackingArea:_snapbackTrackingArea];
    }
	
	// We're not to be tracked if we're not enabled
	if ([self isEnabled]) {
		// We're either in recording or normal display mode
		if (!_recording) {
			// Create and register tracking rect for the remove badge if shortcut is not empty
			NSRect removeButtonRect = [self removeButtonRectForFrame:[self bounds]];
			BOOL mouseInside = [self mouse:mouseLocation inRect:removeButtonRect];
			
			_removeTrackingArea = [[NSTrackingArea alloc] initWithRect:removeButtonRect
                                                               options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                                 owner:self
                                                              userInfo:nil];
			[self addTrackingArea:_removeTrackingArea];
			
			if (_mouseInsideTrackingArea != mouseInside) {
				_mouseInsideTrackingArea = mouseInside;
            }
		}
		else {
			// Create and register tracking rect for the snapback badge if we're in recording mode
			NSRect snapbackRect = [self removeButtonRectForFrame:[self bounds]];
			BOOL mouseInside = [self mouse:mouseLocation inRect:snapbackRect];
			
			_snapbackTrackingArea = [[NSTrackingArea alloc] initWithRect:snapbackRect
                                                                 options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow)
                                                                   owner:self
                                                                userInfo:nil];
			[self addTrackingArea:_snapbackTrackingArea];
			
			if (_mouseInsideTrackingArea != mouseInside) {
				_mouseInsideTrackingArea = mouseInside;
            }
		}
	}
}

- (void)mouseEntered:(NSEvent *)theEvent {
	if ([[self window] isKeyWindow] || [self acceptsFirstMouse:theEvent]) {
		_mouseInsideTrackingArea = YES;
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
	if ([[self window] isKeyWindow] || [self acceptsFirstMouse:theEvent]) {
		_mouseInsideTrackingArea = NO;
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect trackingRect = [self removeButtonRectForFrame:[self bounds]];
    
    _mouseDown = YES;
    _mouseInsideTrackingArea = [self mouse:thePoint inRect:trackingRect];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect trackingRect = [self removeButtonRectForFrame:[self bounds]];
    
    _mouseInsideTrackingArea = [self mouse:thePoint inRect:trackingRect];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect trackingRect = [self removeButtonRectForFrame:[self bounds]];
    
    _mouseDown = NO;
    _mouseInsideTrackingArea = [self mouse:thePoint inRect:trackingRect];
    
    if (_mouseInsideTrackingArea) {
        if (_recording) {
            // Mouse was over snapback, just redraw
            [self endRecording];
        }
        else {
            // Mouse was over the remove image, reset all
            [self setKeyCombination:nil];
            if (self.action != NULL) {
                [[NSApplication sharedApplication] sendAction:self.action to:self.target from:self];
            }
        }
    }
    else if ([self mouse:thePoint inRect:[self bounds]] && !_recording) {
        if ([self isEnabled]) {
            [self startRecording];
        }
    }
    
    // Any click inside will make us firstResponder
    if ([self isEnabled]) {
        [[self window] makeFirstResponder:self];
    }
    
    // Reset tracking rects and redisplay
    [self updateTrackingAreas];
    [self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark Recording

- (void)startRecording {
    // Jump into recording mode if mouse was inside the control but not over any image
    _recording = YES;
    
    // Reset recording flags and determine which are required
    _recordingModifierFlags = [self filteredModifierFlags:0];
    
	[self setNeedsDisplay:YES];
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    
    if (self.allowsGlobalHotKeys) {
		_hotKeyModeToken = PushSymbolicHotKeyMode(kHIHotKeyModeAllDisabled);
    }
}

- (void)endRecording {
    _recording = NO;
    
	[self setNeedsDisplay:YES];
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
	
	if (_hotKeyModeToken) {
		PopSymbolicHotKeyMode(_hotKeyModeToken);
    }
}

- (PXKeyModifierFlags)filteredModifierFlags:(PXKeyModifierFlags)flags {
	NSUInteger filteredFlags = 0;
	NSUInteger a = _allowedModifierFlags;
	NSUInteger m = _requiredModifierFlags;
    
	if (m & PXKeyModifierCommand) {
        filteredFlags |= PXKeyModifierCommand;
    }
	else if ((flags & PXKeyModifierCommand) && (a & PXKeyModifierCommand)) {
        filteredFlags |= PXKeyModifierCommand;
    }
    
	if (m & PXKeyModifierAlternate) {
        filteredFlags |= PXKeyModifierAlternate;
    }
	else if ((flags & PXKeyModifierAlternate) && (a & PXKeyModifierAlternate)) {
        filteredFlags |= PXKeyModifierAlternate;
    }
    
	if (m & PXKeyModifierControl) {
        filteredFlags |= PXKeyModifierControl;
    }
	else if ((flags & PXKeyModifierControl) && (a & PXKeyModifierControl)) {
        filteredFlags |= PXKeyModifierControl;
    }
    
	if (m & PXKeyModifierShift) {
        filteredFlags |= PXKeyModifierShift;
    }
	else if ((flags & PXKeyModifierShift) && (a & PXKeyModifierShift)) {
        filteredFlags |= PXKeyModifierShift;
    }
	
	return filteredFlags;
}

- (BOOL)validModifierFlags:(PXKeyModifierFlags)flags {
    if (self.allowsKeyOnly) {
        return YES;
    }
    else {
        return ((flags & PXKeyModifierCommand) || (flags & PXKeyModifierAlternate) || (flags & PXKeyModifierControl) || (flags & PXKeyModifierShift));
    }
}


#pragma mark -
#pragma mark Key Interception

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	// Only if we're key, please. Otherwise hitting Space after having
	// tabbed past SRRecorderControl will put you into recording mode.
	if ([[self window] firstResponder] == self) {
        NSNumber *keyCodeNumber = [NSNumber numberWithUnsignedShort:[theEvent keyCode]];
        
        PXKeyModifierFlags flags = [self filteredModifierFlags:(PXKeyModifierFlags)[theEvent modifierFlags]];;
        
        // Snapback key shouldn't interfer with required flags!
        BOOL snapback = [_cancelCharacterSet containsObject:keyCodeNumber];
        BOOL validModifiers = [self validModifierFlags:(snapback) ? (PXKeyModifierFlags)[theEvent modifierFlags] : flags];
        
        // Special case for the space key when we aren't recording...
        NSString *eventCharacters = [theEvent characters];
        if (!_recording) {
            if ([eventCharacters length] == 1) {
                unichar eventCharacter = [eventCharacters characterAtIndex:0];
                switch (eventCharacter) {
                    case ' ':
                        [self startRecording];
                        return YES;
                        
                    case 0x7F:   // left delete
                    case 0xF728: // right delete
                        [self setKeyCombination:nil];
                        if (self.action != NULL) {
                            [[NSApplication sharedApplication] sendAction:self.action to:self.target from:self];
                        }
                        return YES;
                        
                    default:
                        return NO;
                }
            }
        }
        
        // Do something as long as we're in recording mode and a modifier key or cancel key is pressed
        if (_recording && (validModifiers || snapback)) {
            if (!snapback || validModifiers) {
                BOOL goAhead = YES;
                
                // Special case: if a snapback key has been entered AND modifiers are deemed valid...
                if (snapback && validModifiers) {
                    // ...AND we're set to allow plain keys
                    if (self.allowsKeyOnly) {
                        // ...AND modifiers are empty, or empty save for the Function key
                        // (needed, since forward delete is fn+delete on laptops)
                        if (flags == 0) {
                            // ...check for behavior in escapeKeysRecord.
                            if (!self.allowsEscapeKeys) {
                                goAhead = NO;
                            }
                        }
                    }
                }
                
                if (goAhead) {
                    NSString *character = [[theEvent charactersIgnoringModifiers] uppercaseString];
                    
                    // Accents like "¬¥" or "`" will be ignored since we don't get a keycode
                    if ([character length] > 0) {
                        NSError *error = nil;
                        
                        PXKeyCombination *combination = [[PXKeyCombination alloc] initWithKeyCode:[theEvent keyCode] modifierFlags:flags];
                        
                        // Check if key combination is already used or not allowed by the delegate
                        if ([_validator isKeyCombinationTaken:combination error:&error]) {
                            // display the error...
                            NSAlert *alert = [NSAlert alertWithError:error];
                            [alert setAlertStyle:NSCriticalAlertStyle];
                            [alert runModal];
                            
                            // Recheck pressed modifier keys
                            [self flagsChanged:[[NSApplication sharedApplication] currentEvent]];
                            
                            return YES;
                        }
                        else {
                            // All ok, set new combination
                            self.keyCombination = combination;
                            if (self.action != NULL) {
                                [[NSApplication sharedApplication] sendAction:self.action to:self.target from:self];
                            }
                        }
                    }
                    else {
                        // Invalid character
                        NSBeep();
                    }
                }
            }
            
            // Reset values and redisplay
            _recordingModifierFlags = 0;
            
            [self endRecording];
            
            [self updateTrackingAreas];
            
            return YES;
        }
        else {
            // Start recording when the spacebar is pressed while the control is first responder
            
            if ([[self window] firstResponder] == self
                && [self isEnabled]
                && [eventCharacters length] == 1)
            {
                unichar eventCharacter = [eventCharacters characterAtIndex:0];
                switch (eventCharacter) {
                    case ' ':       // Space
                    case 0x7F:      // Left delete
                    case 0xF728:    // Right delete
                        NSBeep();
                        return YES;
                }
            }
        }
        
        return NO;
	}
	return [super performKeyEquivalent:theEvent];
}

- (void)flagsChanged:(NSEvent *)theEvent {
	if (_recording) {
		_recordingModifierFlags = [self filteredModifierFlags:(PXKeyModifierFlags)[theEvent modifierFlags]];
	}
    [self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)theEvent {
	if ([[self cell] performKeyEquivalent:theEvent]) {
        return;
    }
    [super keyDown:theEvent];
}

@end
