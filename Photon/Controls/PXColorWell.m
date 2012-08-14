//
//  PXColorWell.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXColorWell.h"
#import "PXColorPickerView.h"
#import <QuartzCore/QuartzCore.h>


@interface PXColorWellPopupWindow : NSWindow

- (id)initWithContentRect:(NSRect)contentRect;

@end


@interface PXColorWellPopUpContentView : NSView

@property (strong) PXColorWellCell *colorWellCell;

@end


@interface PXColorWellCell ()

- (void)closePicker;

@end


NSString * const PXColorWellCellWillPopUpColorPickerNotification = @"PXColorWellCellWillPopUpColorPicker";


@implementation PXColorWell

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"textColorWell"]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"cell.textColorWell", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    else if ([key isEqualToString:@"color"]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"cell.color", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    else if ([key isEqualToString:@"allowsTransparent"]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"cell.allowsTransparent", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    return keyPaths;
}

+ (void)initialize {
    if (self == [PXColorWell class]) {
        [self setCellClass:[PXColorWellCell class]];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([aDecoder containsValueForKey:@"color"]) {
            self.color = [aDecoder decodeObjectForKey:@"color"];
        }
        self.allowsTransparent = [aDecoder decodeBoolForKey:@"allowsTransparent"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeBool:self.allowsTransparent forKey:@"allowsTransparent"];
}

- (NSColor *)color {
    return [[self cell] color];
}

- (void)setColor:(NSColor *)aColor {
    [[self cell] setColor:aColor];
}

- (PXColorWell *)textColorWell {
    return [[self cell] textColorWell];
}

- (void)setTextColorWell:(PXColorWell *)aTextColorWell {
    [[self cell] setTextColorWell:aTextColorWell];
}

- (BOOL)allowsTransparent {
    return [[self cell] allowsTransparent];
}

- (void)setAllowsTransparent:(BOOL)flag {
    [[self cell] setAllowsTransparent:flag];
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    // Push bindings to cell
    [[self cell] bind:binding toObject:observable withKeyPath:keyPath options:options];
}

- (void)unbind:(NSString *)binding {
    // Push bindings to cell
    [[self cell] unbind:binding];
}

@end


@implementation PXColorWellCell {
    NSWindow *_popupWindow;
    NSColor *_color;
    BOOL _allowsTransparent;
    id _colorPicker;
    PXColorWell *_textColorWell;
    NSTimer *hideTimer;
}

@synthesize textColorWell=_textColorWell;

+ (void)initialize {
    [self exposeBinding:NSValueBinding];
}

- (void)commonInit {
    _color = [NSColor blueColor];
    
    _popupWindow = [[PXColorWellPopupWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 168.0, 178.0)];
    
    PXColorWellPopUpContentView *contentView = [[PXColorWellPopUpContentView alloc] initWithFrame:[[_popupWindow contentView] frame]];
    [_popupWindow setContentView:contentView];
    [contentView setColorWellCell:self];
    
    _colorPicker = [[PXColorPickerView alloc] initWithFrame:NSMakeRect(0.0, 2.0, 168.0, 164.0)];
    [_colorPicker setColorWellCell:self];
    [contentView addSubview:_colorPicker];
    
    [self addObserver:self forKeyPath:@"textColorWell.color" options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorWellCellWillPopUpColorPicker:) name:PXColorWellCellWillPopUpColorPickerNotification object:nil];
    
    CAAnimation *animation = [CABasicAnimation animation];
    animation.duration = 0.2;
    [animation setDelegate:self];
    [_popupWindow setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"alphaValue"]];
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initTextCell:(NSString *)aString {
    self = [super initTextCell:aString];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initImageCell:(NSImage *)anImage {
    self = [super initImageCell:anImage];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
        
        if ([aDecoder containsValueForKey:@"color"])
            self.color = [aDecoder decodeObjectForKey:@"color"];
        self.allowsTransparent = [aDecoder decodeBoolForKey:@"allowsTransparent"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_color forKey:@"color"];
    [aCoder encodeBool:_allowsTransparent forKey:@"allowsTransparent"];
}

- (id)copyWithZone:(NSZone *)zone {
    PXColorWellCell *cell = [super copyWithZone:zone];
    
    cell->_color = [_color copy];
    cell->_allowsTransparent = _allowsTransparent;
    
    return cell;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObserver:self forKeyPath:@"textColorWell.color"];
    
    _popupWindow = nil;
    _colorPicker = nil;
    _textColorWell = nil;
    _color = nil;
    [hideTimer invalidate], hideTimer = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"textColorWell.color"]) {
        [[self controlView] setNeedsDisplay:YES];
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)changeColor:(id)sender {
    [self setColor:[sender color]];
    [NSApp sendAction:[self action] to:[self target] from:self];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if ([_popupWindow alphaValue] == 0.0) {
        [_popupWindow orderOut:nil];
        [_popupWindow setAlphaValue:1.0];
    }
}

- (void)closePicker {
    [[_popupWindow parentWindow] removeChildWindow:_popupWindow];
    [[_popupWindow animator] setAlphaValue:0.0];
}

- (void)closePicker:(id)sender {
    [self closePicker];
    
    if (sender == hideTimer) {
        hideTimer = nil;
    }
}

- (void)mouseEnteredColorPicker:(NSEvent *)theEvent {
    if (hideTimer != nil) {
        [hideTimer invalidate], hideTimer = nil;
    }
}

- (void)mouseExitedColorPicker:(NSEvent *)theEvent {
    hideTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(closePicker:) userInfo:nil repeats:NO];
}

- (void)colorWellCellWillPopUpColorPicker:(NSNotification *)notification {
    if ([notification object] != self) {
        if (hideTimer != nil) {
            [hideTimer invalidate], hideTimer = nil;
        }
        [self closePicker];
    }
}


#pragma mark -
#pragma mark Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(cellFrame, 0.5, 0.5)];
    NSBezierPath *topPath = [NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX(cellFrame), NSMinY(cellFrame), NSWidth(cellFrame), floor(NSHeight(cellFrame) / 2.0))];
    NSBezierPath *bottomPath = [NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX(cellFrame), NSMinY(cellFrame) + floor(NSHeight(cellFrame) / 2.0), NSWidth(cellFrame), ceil(NSHeight(cellFrame) / 2.0))];
    NSGradient *gradient;
    
    if (![self isEnabled]) {
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.98 alpha:1.0]
                                                 endingColor:[NSColor colorWithCalibratedWhite:0.92 alpha:1.0]];
    }
    else if ([self isHighlighted]) {
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]
                                                 endingColor:[NSColor colorWithCalibratedWhite:0.7 alpha:1.0]];
    }
    else {
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
                                                 endingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]];
    }
    
    [gradient drawInBezierPath:topPath angle:90.0];
    [gradient drawInBezierPath:bottomPath angle:-90.0];
    
    if (![self isEnabled]) {
        [[NSColor colorWithCalibratedWhite:0.8 alpha:1.0] set];
        [path stroke];
    }
    else {
        [[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
        [path stroke];
    }
    
    [self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    CGFloat inset = 5.0;
    if ([self controlSize] == NSSmallControlSize || [self controlSize] == NSMiniControlSize) {
        inset = 3.0;
    }
    NSBezierPath *fill = [NSBezierPath bezierPathWithRect:NSInsetRect(cellFrame, inset, inset)];
    NSBezierPath *stroke = [NSBezierPath bezierPathWithRect:NSInsetRect(cellFrame, inset + 0.5, inset + 0.5)];
    
    if (_color) {
        [_color set];
        [fill fill];
    } else {
        [[NSColor whiteColor] set];
        [fill fill];
        NSRect rect = NSInsetRect(cellFrame, inset + 1.0, inset + 1.0);
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
    
    if (_textColorWell) {
        NSString *character = [NSString stringWithFormat:@"a"];
        NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [para setAlignment:NSCenterTextAlignment];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSFont fontWithName:@"Times New Roman" size:14.0], NSFontAttributeName,
                                    [_textColorWell color], NSForegroundColorAttributeName,
                                    para, NSParagraphStyleAttributeName,
                                    nil];
        NSRect characterRect = NSMakeRect(5.0, round((NSHeight(cellFrame)-[character sizeWithAttributes:attributes].height) / 2.0), NSWidth(cellFrame) - 10.0, [character sizeWithAttributes:attributes].height);
        [character drawInRect:characterRect withAttributes:attributes];
    }
}


#pragma mark -
#pragma mark Accessors

- (NSColor *)color {
    return [_color copy];
}

- (void)setColor:(NSColor *)color {
    if (color != _color) {
        [self willChangeValueForKey:@"color"];
        _color = [color copy];
        [self didChangeValueForKey:@"color"];
        [[self controlView] setNeedsDisplay:YES];
    }
}

- (BOOL)allowsTransparent {
    return _allowsTransparent;
}

- (void)setAllowsTransparent:(BOOL)flag {
    [self willChangeValueForKey:@"allowsTransparent"];
    _allowsTransparent = flag;
    [_colorPicker setAllowsTransparent:flag];
    [self didChangeValueForKey:@"allowsTransparent"];
}


#pragma mark -
#pragma mark Tracking

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp {
    BOOL keepOn = YES;
    while (keepOn) {
        // We're dragging outside the button, wait for a mouseup or move back inside
        theEvent = [[controlView window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        keepOn = ([theEvent type] == NSLeftMouseDragged);
    }
    
    NSWindow *parentWindow = [[self controlView] window];
    NSPoint origin = [parentWindow convertBaseToScreen:[controlView convertPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height + 2.0) toView:nil]];
    origin.x -= round(fabs((cellFrame.size.width - [_popupWindow frame].size.width)) / 2.0);
    origin.y -= round(cellFrame.size.height * 0.75);
    
    NSRect screenFrame = [[parentWindow screen] visibleFrame];
    if (origin.x < screenFrame.origin.x) {
        origin.x = screenFrame.origin.x;
    }
    if (origin.x + [_popupWindow frame].size.width > screenFrame.size.width) {
        origin.x -= ((origin.x + [_popupWindow frame].size.width) - screenFrame.size.width);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PXColorWellCellWillPopUpColorPickerNotification object:self];
    
    [_popupWindow setFrameTopLeftPoint:origin];
    [parentWindow addChildWindow:_popupWindow ordered:NSWindowAbove];
    [_popupWindow setAlphaValue:0.0];
    [_popupWindow orderFront:self];
    [[_popupWindow animator] setAlphaValue:1.0];
    
    return YES;
}


#pragma mark -
#pragma mark Bindings

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    if ([binding isEqualToString:NSValueBinding]) {
        [super bind:@"color" toObject:observable withKeyPath:keyPath options:options];
    }
}

- (void)unbind:(NSString *)binding {
    if ([binding isEqualToString:NSValueBinding]) {
        [super unbind:@"color"];
    }
}

@end


@implementation PXColorWellPopupWindow

- (id)initWithContentRect:(NSRect)contentRect {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    if (self) {
        [self setBackgroundColor:[NSColor clearColor]];
        [self setMovableByWindowBackground:NO];
        [self setOpaque:NO];
        [self setHasShadow:YES];
    }
    return self;
}

@end


@implementation PXColorWellPopUpContentView {
    NSTrackingArea *trackingArea;
}

@synthesize colorWellCell;

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self updateTrackingAreas];
    }
    return self;
}

- (void)updateTrackingAreas {
    if (trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
        trackingArea = nil;
    }
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect] options:(NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp|NSTrackingInVisibleRect) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect backgroundRect = NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), NSWidth([self bounds]), NSHeight([self bounds]) - 10.0);
    
    [[NSColor controlBackgroundColor] set];
    
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:backgroundRect xRadius:5.0 yRadius:5.0];
    [backgroundPath fill];
    
    NSBezierPath *arrowPath = [NSBezierPath bezierPath];
    [arrowPath moveToPoint:NSMakePoint(NSMidX([self bounds]), NSMaxY([self bounds]))];
    [arrowPath relativeLineToPoint:NSMakePoint(-8.0, -10.0)];
    [arrowPath relativeLineToPoint:NSMakePoint(16.0, 0.0)];
    [arrowPath closePath];
    [arrowPath fill];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [colorWellCell mouseEnteredColorPicker:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [colorWellCell mouseExitedColorPicker:theEvent];
}

@end
