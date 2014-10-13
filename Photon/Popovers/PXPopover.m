//
//  PXPopover.m
//  Photon
//
//  Created by Logan Collins on 2/27/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "PXPopover.h"
#import "PXPopover_Private.h"

#import "PXAccessibility.h"
#import "NSObject+PhotonAdditions.h"
#import <objc/runtime.h>


NSString * const PXPopoverWillShowNotification = @"PXPopoverWillShowNotification";
NSString * const PXPopoverDidShowNotification = @"PXPopoverDidShowNotification";
NSString * const PXPopoverWillDismissNotification = @"PXPopoverWillDismissNotification";
NSString * const PXPopoverDidDismissNotification = @"PXPopoverDidDismissNotification";

    
@implementation PXPopover {
    NSViewController *_contentViewController;
    NSSize _contentSize;
    
    NSView *_positioningView;
    NSRect _positioningRect;
    
    PXPopoverWindow *_popoverWindow;
    PXPopoverBackgroundView *_backgroundView;
}

+ (void)initialize {
    if (self == [PXPopover class]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [NSWindow px_exchangeInstanceMethodForSelector:@selector(hasKeyAppearance) withSelector:@selector(px_hasKeyAppearance)];
#pragma clang diagnostic pop
    }
}

- (id)initWithContentViewController:(NSViewController *)viewController {
    self = [self init];
    if (self) {
        self.contentViewController = viewController;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.arrowDirection = PXPopoverArrowDirectionUnknown;
    }
    return self;
}


#pragma mark -
#pragma mark Accessors

- (NSViewController *)contentViewController {
    return _contentViewController;
}

- (void)setContentViewController:(NSViewController *)contentViewController {
    [self setContentViewController:contentViewController animated:NO];
}

- (void)setContentViewController:(NSViewController *)contentViewController animated:(BOOL)animated {
    NSParameterAssert(contentViewController != nil);
    
    _contentViewController = contentViewController;
    
    NSSize contentSize = [[contentViewController view] frame].size;
    _contentSize = contentSize;
}

- (NSSize)contentSize {
    return _contentSize;
}

- (void)setContentSize:(NSSize)contentSize {
    [self setContentSize:contentSize animated:NO];
}

- (void)setContentSize:(NSSize)contentSize animated:(BOOL)animated {
    NSParameterAssert(!NSEqualSizes(contentSize, NSZeroSize));
}

- (PXPopoverBackgroundView *)backgroundView {
    return _backgroundView;
}

- (NSView *)positioningView {
    return _positioningView;
}

- (NSWindow *)window {
    return _popoverWindow;
}


#pragma mark -
#pragma mark Presentation

- (void)makeKeyAndShowRelativeToRect:(NSRect)rect ofView:(NSView *)view permittedArrowDirections:(PXPopoverArrowDirection)arrowDirection animated:(BOOL)animated {
    [self showRelativeToRect:rect ofView:view permittedArrowDirections:arrowDirection animated:animated makeKey:YES];
}

- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)view permittedArrowDirections:(PXPopoverArrowDirection)arrowDirection animated:(BOOL)animated {
    [self showRelativeToRect:rect ofView:view permittedArrowDirections:arrowDirection animated:animated makeKey:NO];
}

- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)view permittedArrowDirections:(PXPopoverArrowDirection)arrowDirection animated:(BOOL)animated makeKey:(BOOL)makeKey {
    NSParameterAssert(self.contentViewController != nil);
    NSParameterAssert(view != nil);
    NSParameterAssert(arrowDirection != PXPopoverArrowDirectionUnknown);
    
    if ([view isHiddenOrHasHiddenAncestor]) {
        return;
    }
    
    if (NSEqualRects(rect, NSZeroRect)) {
        rect = [view bounds];
    }
    
    _positioningView = view;
    _positioningRect = rect;
    
    
    Class backgroundViewClass = self.backgroundViewClass;
    if (backgroundViewClass == Nil) {
        backgroundViewClass = [PXConcretePopoverBackgroundView class];
    }
    
    if (_backgroundView == nil) {
        _backgroundView = [[backgroundViewClass alloc] initWithFrame:NSMakeRect(0.0, 0.0, _contentSize.width, _contentSize.height)];
        _backgroundView.popover = self;
    }
    
    
//    NSScreen *screen = nil;
    NSRect screenRect = [[view window] convertRectToScreen:[view convertRect:rect toView:nil]];
    
//    NSSize requiredSize = NSMakeSize(_contentSize.width + [backgroundViewClass arrowHeight], _contentSize.height + [backgroundViewClass arrowHeight]);
    NSEdgeInsets contentViewInsets = [backgroundViewClass contentViewInsets];
    
    PXPopoverArrowDirection chosenArrowDirection = PXPopoverArrowDirectionUnknown;
    if (arrowDirection & PXPopoverArrowDirectionUp) {
        chosenArrowDirection = PXPopoverArrowDirectionUp;
    }
    else if (arrowDirection & PXPopoverArrowDirectionDown) {
        chosenArrowDirection = PXPopoverArrowDirectionDown;
    }
    else if (arrowDirection & PXPopoverArrowDirectionLeft) {
        chosenArrowDirection = PXPopoverArrowDirectionLeft;
    }
    else if (arrowDirection & PXPopoverArrowDirectionRight) {
        chosenArrowDirection = PXPopoverArrowDirectionRight;
    }
    
    NSSize backgroundSize = NSMakeSize(_contentSize.width + (contentViewInsets.left + contentViewInsets.right), _contentSize.height + (contentViewInsets.top + contentViewInsets.bottom));
    NSRect contentRect = NSMakeRect(contentViewInsets.left, contentViewInsets.bottom, _contentSize.width, _contentSize.height);
    NSPoint originPoint = NSZeroPoint;
    
    if (chosenArrowDirection == PXPopoverArrowDirectionUp) {
        backgroundSize.height += [backgroundViewClass arrowHeight];
        originPoint = NSMakePoint(NSMinX(screenRect) + round((screenRect.size.width - backgroundSize.width) / 2.0), NSMinY(screenRect) - backgroundSize.height);
    }
    else if (chosenArrowDirection == PXPopoverArrowDirectionDown) {
        backgroundSize.height += [backgroundViewClass arrowHeight];
        contentRect.origin.y += [backgroundViewClass arrowHeight];
        originPoint = NSMakePoint(NSMinX(screenRect) + round((screenRect.size.width - backgroundSize.width) / 2.0), NSMaxY(screenRect));
    }
    else if (chosenArrowDirection == PXPopoverArrowDirectionLeft) {
        backgroundSize.width += [backgroundViewClass arrowHeight];
        contentRect.origin.x += [backgroundViewClass arrowHeight];
        originPoint = NSMakePoint(NSMaxX(screenRect), NSMinY(screenRect) + round((screenRect.size.height - backgroundSize.height) / 2.0));
    }
    else if (chosenArrowDirection == PXPopoverArrowDirectionRight) {
        backgroundSize.height += [backgroundViewClass arrowHeight];
        originPoint = NSMakePoint(NSMinX(screenRect) - backgroundSize.width, NSMinY(screenRect) + round((screenRect.size.height - backgroundSize.height) / 2.0));
    }
    
    
    [self.contentViewController px_setPopover:self];
    
    id accessibilityTarget = [_positioningView px_accessibilityOverrideTargetForAttribute:NSAccessibilityChildrenAttribute];
    NSArray *accessibilityChildren = nil;
    if ([[accessibilityTarget accessibilityAttributeNames] containsObject:NSAccessibilityChildrenAttribute]) {
        accessibilityChildren = [_positioningView accessibilityAttributeValue:NSAccessibilityChildrenAttribute];
    }
    [accessibilityTarget accessibilitySetOverrideValue:(accessibilityChildren != nil ? [accessibilityChildren arrayByAddingObject:_backgroundView] : @[_backgroundView]) forAttribute:NSAccessibilityChildrenAttribute];
    
    NSWindow *parentWindow = [view window];
    
    [_backgroundView setFrame:CGRectMake(0.0, 0.0, backgroundSize.width, backgroundSize.height)];
    
    NSView *contentView = [self.contentViewController view];
    [contentView setFrame:contentRect];
    contentView.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
    contentView.translatesAutoresizingMaskIntoConstraints = YES;
    [_backgroundView setSubviews:@[contentView]];
    
    _backgroundView.arrowDirection = chosenArrowDirection;
    
    
    if ([self.delegate respondsToSelector:@selector(popoverWillShow:)]) {
        [self.delegate popoverWillShow:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PXPopoverWillShowNotification object:self userInfo:nil];
    
    
    NSRect windowRect = NSMakeRect(originPoint.x, originPoint.y, backgroundSize.width, backgroundSize.height);
    
    _popoverWindow = [[PXPopoverWindow alloc] initWithContentRect:windowRect styleMask:(NSBorderlessWindowMask|NSNonactivatingPanelMask) backing:NSBackingStoreBuffered defer:YES];
    [_popoverWindow setLevel:NSSubmenuWindowLevel];
    [_popoverWindow setContentView:_backgroundView];
    [_popoverWindow setHasShadow:YES];
    [_popoverWindow setOpaque:NO];
    [_popoverWindow setBackgroundColor:[NSColor clearColor]];
    
    [parentWindow px_setPresentedPopover:self];
    
    if (animated) {
        [_popoverWindow setAlphaValue:0.0];
    }
    
    [parentWindow addChildWindow:_popoverWindow ordered:NSWindowAbove];
    if (makeKey) {
        [_popoverWindow makeKeyWindow];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:_popoverWindow];
    
    if (animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.2;
            [[_popoverWindow animator] setAlphaValue:1.0];
        } completionHandler:^{
            self.shown = YES;
            self.arrowDirection = chosenArrowDirection;
            
            if ([self.delegate respondsToSelector:@selector(popoverDidShow:)]) {
                [self.delegate popoverDidShow:self];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PXPopoverDidShowNotification object:self userInfo:nil];
        }];
    }
    else {
        self.shown = YES;
        self.arrowDirection = chosenArrowDirection;
        
        if ([self.delegate respondsToSelector:@selector(popoverDidShow:)]) {
            [self.delegate popoverDidShow:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PXPopoverDidShowNotification object:self userInfo:nil];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(popoverWillDismiss:)]) {
        [self.delegate popoverWillDismiss:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PXPopoverWillDismissNotification object:self userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:_popoverWindow];
    
    void (^handler)(void) = ^{
        [self.contentViewController px_setPopover:nil];
        [_popoverWindow orderOut:nil];
        [[_popoverWindow parentWindow] px_setPresentedPopover:nil];
        [[_popoverWindow parentWindow] removeChildWindow:_popoverWindow];
        _popoverWindow = nil;
        
        id accessibilityTarget = [_positioningView px_accessibilityOverrideTargetForAttribute:NSAccessibilityChildrenAttribute];
        [accessibilityTarget accessibilitySetOverrideValue:nil forAttribute:NSAccessibilityChildrenAttribute];
        
        _backgroundView = nil;
        
        self.shown = NO;
        self.arrowDirection = PXPopoverArrowDirectionUnknown;
        
        if ([self.delegate respondsToSelector:@selector(popoverDidDismiss:)]) {
            [self.delegate popoverDidDismiss:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PXPopoverDidDismissNotification object:self userInfo:nil];
    };
    
    if (animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.2;
            [[_popoverWindow animator] setAlphaValue:0.0];
        } completionHandler:handler];
    }
    else {
        handler();
    }
}

- (void)windowDidResignKey:(NSNotification *)notification {
    if (self.shown) {
        [self dismissAnimated:YES];
    }
}

@end


@implementation PXPopoverWindow

- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end


@implementation PXPopoverBackgroundView

+ (NSEdgeInsets)contentViewInsets {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Subclasses must override %@", NSStringFromSelector(_cmd)] userInfo:nil];
}

+ (CGFloat)arrowHeight {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Subclasses must override %@", NSStringFromSelector(_cmd)] userInfo:nil];
}

+ (CGFloat)arrowBase {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Subclasses must override %@", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (CGFloat)arrowOffset {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Subclasses must override %@", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)setArrowOffset:(CGFloat)arrowOffset {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Subclasses must override %@", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (PXPopoverArrowDirection)arrowDirection {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Subclasses must override %@", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)setArrowDirection:(PXPopoverArrowDirection)arrowDirection {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Subclasses must override %@", NSStringFromSelector(_cmd)] userInfo:nil];
}


#pragma mark -
#pragma mark Accessibility

- (BOOL)accessibilityIsIgnored {
    return NO;
}

- (id)accessibilityAttributeValue:(NSString *)attribute {
    if ([attribute isEqualToString:NSAccessibilityRoleAttribute]) {
        return NSAccessibilityPopoverRole;
    }
    else if ([attribute isEqualToString:NSAccessibilityParentAttribute]) {
        return [[[self popover] positioningView] px_accessibilityOverrideTargetForAttribute:NSAccessibilityChildrenAttribute];
    }
    return [super accessibilityAttributeValue:attribute];
}

@end


@implementation PXConcretePopoverBackgroundView {
    CGFloat _arrowOffset;
    PXPopoverArrowDirection _arrowDirection;
}

+ (NSEdgeInsets)contentViewInsets {
    return NSEdgeInsetsMake(3.0, 3.0, 3.0, 3.0);
}

+ (CGFloat)arrowHeight {
    return 12.0;
}

+ (CGFloat)arrowBase {
    return 24.0;
}

- (CGFloat)arrowOffset {
    return _arrowOffset;
}

- (void)setArrowOffset:(CGFloat)arrowOffset {
    _arrowOffset = arrowOffset;
    [self setNeedsDisplay:YES];
}

- (PXPopoverArrowDirection)arrowDirection {
    return _arrowDirection;
}

- (void)setArrowDirection:(PXPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    
    NSRect backgroundRect = bounds;
    
    NSBezierPath *backgroundPath = [NSBezierPath bezierPath];
    
    CGFloat cornerRadius = 4.0;
    CGFloat arrowHeight = [[self class] arrowHeight];
    CGFloat arrowBase = [[self class] arrowBase];
    CGFloat arrowOffset = [self arrowOffset];
    
    if (_arrowDirection == PXPopoverArrowDirectionUp) {
        backgroundRect.size.height -= arrowHeight;
        
        [backgroundPath moveToPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMaxY(bounds) - arrowHeight)];
        [backgroundPath lineToPoint:NSMakePoint(NSMidX(bounds) + arrowOffset - round(arrowBase / 2.0), NSMaxY(bounds) - arrowHeight)];
        [backgroundPath lineToPoint:NSMakePoint(NSMidX(bounds) + arrowOffset, NSMaxY(bounds))];
        [backgroundPath lineToPoint:NSMakePoint(NSMidX(bounds) + arrowOffset + round(arrowBase / 2.0), NSMaxY(bounds) - arrowHeight)];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds) - cornerRadius, NSMaxY(bounds) - arrowHeight)];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds) - arrowHeight)
                                                 toPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds) - (arrowHeight + cornerRadius))
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds) + cornerRadius)];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))
                                                 toPoint:NSMakePoint(NSMaxX(bounds) - cornerRadius, NSMinY(bounds))
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMinY(bounds))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))
                                                 toPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds) + cornerRadius)
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds) - (arrowHeight + cornerRadius))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds) - arrowHeight)
                                                 toPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMaxY(bounds) - arrowHeight)
                                                  radius:cornerRadius];
        [backgroundPath closePath];
    }
    else if (_arrowDirection == PXPopoverArrowDirectionDown) {
        backgroundRect.size.height -= arrowHeight;
        backgroundRect.origin.y += arrowHeight;
        
        [backgroundPath moveToPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMaxY(bounds))];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds) - cornerRadius, NSMaxY(bounds))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))
                                                 toPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds) - cornerRadius)
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds) + (cornerRadius + arrowHeight))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds) + arrowHeight)
                                                 toPoint:NSMakePoint(NSMaxX(bounds) - cornerRadius, NSMinY(bounds) + arrowHeight)
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMidX(bounds) + arrowOffset + round(arrowBase / 2.0), NSMinY(bounds) + arrowHeight)];
        [backgroundPath lineToPoint:NSMakePoint(NSMidX(bounds) + arrowOffset, NSMinY(bounds))];
        [backgroundPath lineToPoint:NSMakePoint(NSMidX(bounds) + arrowOffset - round(arrowBase / 2.0), NSMinY(bounds) + arrowHeight)];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMinY(bounds) + arrowHeight)];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds) + arrowHeight)
                                                 toPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds) + (cornerRadius + arrowHeight))
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds) - cornerRadius)];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))
                                                 toPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMaxY(bounds))
                                                  radius:cornerRadius];
    }
    else if (_arrowDirection == PXPopoverArrowDirectionRight) {
        backgroundRect.size.width -= arrowHeight;
        
        [backgroundPath moveToPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMaxY(bounds))];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds) - (cornerRadius + arrowHeight), NSMaxY(bounds))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bounds) - arrowHeight, NSMaxY(bounds))
                                                 toPoint:NSMakePoint(NSMaxX(bounds) - arrowHeight, NSMaxY(bounds) - cornerRadius)
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds) - arrowHeight, NSMidY(bounds) + arrowOffset + round(arrowBase / 2.0))];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds), NSMidY(bounds) + arrowOffset)];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds) - arrowHeight, NSMidY(bounds) + arrowOffset - round(arrowBase / 2.0))];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds) - arrowHeight, NSMinY(bounds) + (cornerRadius))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bounds) - arrowHeight, NSMinY(bounds))
                                                 toPoint:NSMakePoint(NSMaxX(bounds) - (cornerRadius + arrowHeight), NSMinY(bounds))
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMinY(bounds))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))
                                                 toPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds) + cornerRadius)
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds) - cornerRadius)];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds))
                                                 toPoint:NSMakePoint(NSMinX(bounds) + cornerRadius, NSMaxY(bounds))
                                                  radius:cornerRadius];
    }
    else if (_arrowDirection == PXPopoverArrowDirectionLeft) {
        backgroundRect.size.width -= arrowHeight;
        backgroundRect.origin.x += arrowHeight;
        
        [backgroundPath moveToPoint:NSMakePoint(NSMinX(bounds) + (cornerRadius + arrowHeight), NSMaxY(bounds))];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds) - cornerRadius, NSMaxY(bounds))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds))
                                                 toPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds) - cornerRadius)
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds) + (cornerRadius))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds))
                                                 toPoint:NSMakePoint(NSMaxX(bounds) - cornerRadius, NSMinY(bounds))
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds) + (cornerRadius + arrowHeight), NSMinY(bounds))];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(bounds) + arrowHeight, NSMinY(bounds))
                                                 toPoint:NSMakePoint(NSMinX(bounds) + arrowHeight, NSMinY(bounds) + cornerRadius)
                                                  radius:cornerRadius];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds) + arrowHeight, NSMidY(bounds) + arrowOffset - round(arrowBase / 2.0))];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds), NSMidY(bounds) + arrowOffset)];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds) + arrowHeight, NSMidY(bounds) + arrowOffset + round(arrowBase / 2.0))];
        [backgroundPath lineToPoint:NSMakePoint(NSMinX(bounds) + arrowHeight, NSMaxY(bounds) - cornerRadius)];
        [backgroundPath appendBezierPathWithArcFromPoint:NSMakePoint(NSMinX(bounds) + arrowHeight, NSMaxY(bounds))
                                                 toPoint:NSMakePoint(NSMinX(bounds) + (cornerRadius + arrowHeight), NSMaxY(bounds))
                                                  radius:cornerRadius];
    }
    
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.95 alpha:0.98]
                                                         endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.98]];
    [gradient drawInBezierPath:backgroundPath angle:90.0];
}

@end


@implementation NSViewController (PXPopover)

static NSString * const PXViewControllerPopoverKey = @"PXViewControllerPopover";

- (PXPopover *)px_popover {
    return objc_getAssociatedObject(self, (__bridge void *)PXViewControllerPopoverKey);
}

- (void)px_setPopover:(PXPopover *)popover {
    objc_setAssociatedObject(self, (__bridge void *)PXViewControllerPopoverKey, popover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation NSWindow (PXPopover)

- (BOOL)px_hasKeyAppearance {
    if ([self px_presentedPopover] != nil) {
        if ([[[self px_presentedPopover] window] isKeyWindow]) {
            return YES;
        }
    }
    return [self px_hasKeyAppearance];
}

static NSString * const PXWindowPresentedPopoverKey = @"PXWindowPresentedPopover";

- (PXPopover *)px_presentedPopover {
    return objc_getAssociatedObject(self, (__bridge void *)PXWindowPresentedPopoverKey);
}

- (void)px_setPresentedPopover:(PXPopover *)popover {
    objc_setAssociatedObject(self, (__bridge void *)PXWindowPresentedPopoverKey, popover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
