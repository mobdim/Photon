//
//  PXPopover.m
//  Photon
//
//  Created by Logan Collins on 2/27/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "PXPopover.h"
#import "PXPopover_Private.h"

#import "PXViewController_Private.h"
#import "NSObject+PhotonAdditions.h"
#import <objc/runtime.h>


@implementation PXPopover {
    NSViewController *_contentViewController;
    NSSize _contentSize;
    
    NSView *_positioningView;
    NSRect _positioningRect;
    
    NSWindow *_popoverWindow;
    PXPopoverBackgroundView *_backgroundView;
}

+ (void)initialize {
    if (self == [PXPopover class]) {
//        [NSView px_exchangeInstanceMethodForSelector:@selector(accessibilityAttributeValue:) withSelector:@selector(px_popover_accessibilityAttributeValue:)];
    }
}

- (id)initWithContentViewController:(NSViewController *)viewController {
    self = [super init];
    if (self) {
        self.contentViewController = viewController;
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


#pragma mark -
#pragma mark Presentation

- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)view permittedArrowDirections:(PXPopoverArrowDirection)arrowDirection animated:(BOOL)animated {
    NSParameterAssert(self.contentViewController != nil);
    NSParameterAssert(view != nil);
    NSParameterAssert(arrowDirection != PXPopoverArrowDirectionUnknown);
    
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
    
    
    NSScreen *screen = nil;
    NSRect windowRect = [view convertRect:rect toView:nil];
    NSRect screenRect = [[view window] convertRectToScreen:windowRect];
    
    NSSize requiredSize = NSMakeSize(_contentSize.width + [backgroundViewClass arrowHeight], _contentSize.height + [backgroundViewClass arrowHeight]);
    PXEdgeInsets contentViewInsets = [backgroundViewClass contentViewInsets];
    
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
    NSRect contentRect = NSMakeRect(contentViewInsets.top, contentViewInsets.left, _contentSize.width, _contentSize.height);
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
    
    if (_popoverWindow != nil) {
        
    }
    else {
        [self.contentViewController px_setPopover:self];
        
        NSArray *accessibilityChildren = [_positioningView accessibilityAttributeValue:NSAccessibilityChildrenAttribute];
        [_positioningView accessibilitySetOverrideValue:(accessibilityChildren != nil ? [accessibilityChildren arrayByAddingObject:_backgroundView] : @[_backgroundView]) forAttribute:NSAccessibilityChildrenAttribute];
        
        NSWindow *parentWindow = [view window];
        
        [_backgroundView setFrame:CGRectMake(0.0, 0.0, backgroundSize.width, backgroundSize.height)];
        
        NSView *contentView = [self.contentViewController view];
        [contentView setFrame:contentRect];
        contentView.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
        contentView.translatesAutoresizingMaskIntoConstraints = YES;
        [_backgroundView setSubviews:@[contentView]];
        
        _backgroundView.arrowDirection = chosenArrowDirection;
        
        CGRect windowRect = NSMakeRect(originPoint.x, originPoint.y, backgroundSize.width, backgroundSize.height);
        
        _popoverWindow = [[NSWindow alloc] initWithContentRect:windowRect styleMask:(NSBorderlessWindowMask) backing:NSBackingStoreBuffered defer:YES];
        [_popoverWindow setContentView:_backgroundView];
        [_popoverWindow setHasShadow:YES];
        [_popoverWindow setOpaque:NO];
        [_popoverWindow setBackgroundColor:[NSColor clearColor]];
        
        [parentWindow addChildWindow:_popoverWindow ordered:NSWindowAbove];
        [_popoverWindow orderFront:nil];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    [self.contentViewController px_setPopover:nil];
    
    [_popoverWindow orderOut:nil];
    [[_popoverWindow parentWindow] removeChildWindow:_popoverWindow];
    _popoverWindow = nil;
    
    [_positioningView accessibilitySetOverrideValue:nil forAttribute:NSAccessibilityChildrenAttribute];
    
    _backgroundView = nil;
}

@end


@implementation PXPopoverBackgroundView

+ (PXEdgeInsets)contentViewInsets {
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
        return [[self popover] positioningView];
    }
    return [super accessibilityAttributeValue:attribute];
}

@end


@implementation PXConcretePopoverBackgroundView {
    CGFloat _arrowOffset;
    PXPopoverArrowDirection _arrowDirection;
}

+ (PXEdgeInsets)contentViewInsets {
    return PXEdgeInsetsMake(3.0, 3.0, 3.0, 3.0);
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
    PXViewControllerProxy *proxy = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerPopoverKey);
    return proxy.object;
}

- (void)px_setPopover:(PXPopover *)popover {
    PXViewControllerProxy *proxy = [[PXViewControllerProxy alloc] init];
    proxy.object = popover;
    objc_setAssociatedObject(self, (__bridge void *)PXViewControllerPopoverKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
