//
//  PXNavigationBar.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationBar.h"
#import "PXNavigationItem_Private.h"
#import "PXBarButtonItem.h"

#import <QuartzCore/QuartzCore.h>


typedef PHOTON_ENUM(NSUInteger, PXNavigationDirection) {
    PXNavigationDirectionPush = 0,
    PXNavigationDirectionPop,
};


@implementation PXNavigationBar {
    NSMutableArray *_items;
    NSMutableArray *_constraints;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _items = [NSMutableArray array];
        
        self.style = PXNavigationBarStyleLight;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


#pragma mark -
#pragma mark Layout

- (void)performAppearanceAnimationsForNavigationItem:(PXNavigationItem *)navigationItem backItem:(PXNavigationItem *)backItem direction:(PXNavigationDirection)direction animated:(BOOL)isAnimated {
    NSRect bounds = [self bounds];
    
    [NSAnimationContext beginGrouping];
    
//    NSMutableArray *constraints = [NSMutableArray array];
    
    NSAnimationContext *context = [NSAnimationContext currentContext];
    context.duration = 0.3;
    context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // Back button
    NSButton *backButton = [backItem backButton];
    if (backButton != nil) {
        [backButton sizeToFit];
        backButton.autoresizingMask = (NSViewMaxXMargin|NSViewMinYMargin);
        
        [backButton setTarget:self];
        [backButton setAction:@selector(popAction:)];
        
        [backButton setContentCompressionResistancePriority:750.0 forOrientation:NSLayoutConstraintOrientationHorizontal];
        
        if (isAnimated) {
            if (direction == PXNavigationDirectionPush) {
                [backButton setFrameOrigin:NSMakePoint(5.0 + backButton.frame.size.width, 5.0)];
            }
            else {
                [backButton setFrameOrigin:NSMakePoint(5.0 - backButton.frame.size.width, 5.0)];
            }
            [backButton setAlphaValue:0.0];
            
            [self addSubview:backButton];
            
            [[backButton animator] setFrameOrigin:NSMakePoint(5.0, 5.0)];
            [[backButton animator] setAlphaValue:1.0];
        }
        else {
            [backButton setAlphaValue:1.0];
            [backButton setFrameOrigin:NSMakePoint(5.0, 5.0)];
            [self addSubview:backButton];
        }
    }
    
    // Right accessory view
    PXBarButtonItem *rightBarButtonItem = [navigationItem rightBarButtonItem];
    NSButton *rightButton = nil;
    if (rightBarButtonItem != nil) {
        rightButton = [navigationItem rightButton];
        if (rightButton != nil) {
            [rightButton sizeToFit];
            rightButton.autoresizingMask = (NSViewMinXMargin|NSViewMinYMargin);
            
            [rightButton setTarget:[rightBarButtonItem target]];
            [rightButton setAction:[rightBarButtonItem action]];
            
            [rightButton setFrameOrigin:NSMakePoint(NSMaxX(bounds) - ([rightButton frame].size.width + 5.0), 5.0)];
            [rightButton setContentCompressionResistancePriority:750.0 forOrientation:NSLayoutConstraintOrientationHorizontal];
            
            if (isAnimated) {
                [rightButton setAlphaValue:0.0];
                [self addSubview:rightButton];
                [[rightButton animator] setAlphaValue:1.0];
            }
            else {
                [rightButton setAlphaValue:1.0];
                [self addSubview:rightButton];
            }
        }
    }
    
    // Title view
    id titleView = [navigationItem titleView];
    if (titleView == nil) {
        titleView = [navigationItem titleField];
        [titleView setFont:[NSFont systemFontOfSize:12.0]];
        [titleView setTextColor:[NSColor colorWithCalibratedWhite:0.5 alpha:1.0]];
        [titleView setAlignment:NSCenterTextAlignment];
        [titleView setContentCompressionResistancePriority:250.0 forOrientation:NSLayoutConstraintOrientationHorizontal];
        [[titleView cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
    }
    
    {
//        [titleView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [(NSView *)titleView setAutoresizingMask:(NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin)];
        if ([titleView respondsToSelector:@selector(sizeToFit)]) {
            [titleView sizeToFit];
        }
        
        CGFloat yPos = round((self.bounds.size.height - [titleView frame].size.height) / 2.0);
        if (isAnimated) {
            if (direction == PXNavigationDirectionPush) {
                [titleView setFrameOrigin:NSMakePoint(round((bounds.size.width - [titleView frame].size.width) / 2.0) + 50.0, yPos)];
            }
            else {
                [titleView setFrameOrigin:NSMakePoint(round((bounds.size.width - [titleView frame].size.width) / 2.0) - 50.0, yPos)];
            }
            [titleView setAlphaValue:0.0];
            [self addSubview:titleView];
            [[titleView animator] setAlphaValue:1.0];
            [[titleView animator] setFrameOrigin:NSMakePoint(round((bounds.size.width - [titleView frame].size.width) / 2.0), yPos)];
        }
        else {
            [titleView setFrameOrigin:NSMakePoint(round((bounds.size.width - [titleView frame].size.width) / 2.0), yPos)];
            [titleView setAlphaValue:1.0];
            [self addSubview:titleView];
        }
        
        // Center
//        NSLayoutConstraint *centeringConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
//        [centeringConstraint setPriority:750];
//        [constraints addObject:centeringConstraint];
//        
//        // Leading
//        if (backButton != nil) {
//            NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:backButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
//            [constraints addObject:leadingConstraint];
//        }
//        else {
//            NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:5.0];
//            [constraints addObject:leadingConstraint];
//        }
//        
//        // Trailing
//        if (rightButton != nil) {
//            NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:rightButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:titleView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
//            [constraints addObject:trailingConstraint];
//        }
//        else {
//            NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:5.0];
//            [constraints addObject:trailingConstraint];
//        }
//        
//        // Top
//        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:8.0];
//        [constraints addObject:topConstraint];
    }
    
//    [self addConstraints:constraints];
//    _constraints = constraints;
    
    [NSAnimationContext endGrouping];
}

- (void)performDisappearanceAnimationsForNavigationItem:(PXNavigationItem *)navigationItem backItem:(PXNavigationItem *)backItem direction:(PXNavigationDirection)direction animated:(BOOL)isAnimated {
    NSRect bounds = [self bounds];
    
    [NSAnimationContext beginGrouping];
    
//    NSArray *constraints = _constraints;
    
    // Items
    NSButton *backButton = [backItem backButton];
    
    PXBarButtonItem *rightBarButtonItem = [navigationItem rightBarButtonItem];
    NSButton *rightButton = nil;
    if (rightBarButtonItem != nil) {
        rightButton = [navigationItem rightButton];
    }
    
    id titleView = [navigationItem titleView];
    if (titleView == nil) {
        titleView = [navigationItem titleField];
    }
    
    // Animation
    NSAnimationContext *context = [NSAnimationContext currentContext];
    context.duration = 0.3;
    context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    context.completionHandler = ^{
//        if (_constraints != nil) {
//            // Remove layout constraints before animating
//            [self removeConstraints:constraints];
//        }
        
        [backButton removeFromSuperview];
        [rightButton removeFromSuperview];
        [titleView removeFromSuperview];
    };
    
    // Back button
    if (backButton != nil) {
        if (isAnimated) {
            if (direction == PXNavigationDirectionPop) {
                [[backButton animator] setFrameOrigin:NSMakePoint(5.0 + backButton.frame.size.width, 5.0)];
            }
            else {
                [[backButton animator] setFrameOrigin:NSMakePoint(5.0 - backButton.frame.size.width, 5.0)];
            }
            [[backButton animator] setAlphaValue:0.0];
        }
    }
    
    // Right accessory view
    if (rightButton != nil) {
        if (isAnimated) {
            [[rightButton animator] setAlphaValue:0.0];
        }
    }
    
    // Title view
    if (isAnimated) {
        if (direction == PXNavigationDirectionPop) {
            [[titleView animator] setFrameOrigin:NSMakePoint(round((bounds.size.width - [titleView frame].size.width) / 2.0) + 50.0, 8.0)];
        }
        else {
            [[titleView animator] setFrameOrigin:NSMakePoint(round((bounds.size.width - [titleView frame].size.width) / 2.0) - 50.0, 8.0)];
        }
        [[titleView animator] setAlphaValue:0.0];
    }
    
    [NSAnimationContext endGrouping];
}

- (BOOL)isFlipped {
    return YES;
}

- (IBAction)popAction:(id)sender {
    [self popNavigationItemAnimated:YES];
}


#pragma mark -
#pragma mark Items

+ (NSSet *)keyPathsForValuesAffectingTopItem {
    return [NSSet setWithObjects:@"items", nil];
}

- (PXNavigationItem *)topItem {
    return [_items lastObject];
}

+ (NSSet *)keyPathsForValuesAffectingBackItem {
    return [NSSet setWithObjects:@"items", nil];
}

- (PXNavigationItem *)backItem {
    if ([_items count] > 1) {
        return [_items objectAtIndex:([_items count] - 2)];
    }
    return nil;
}

- (NSArray *)items {
    return [_items copy];
}

- (void)setItems:(NSArray *)items {
    [self setItems:items animated:NO];
}

- (void)setItems:(NSArray *)items animated:(BOOL)isAnimated {
    if (![_items isEqualToArray:items]) {
        PXNavigationItem *newItem = [items lastObject];
        PXNavigationItem *newBackItem = ([items count] > 2 ? [items objectAtIndex:([items count] - 2)] : nil);
        
        BOOL shouldPop = (newItem != nil ? [_items containsObject:newItem] : YES);
        
        PXNavigationItem *currentItem = [self topItem];
        PXNavigationItem *backItem = [self backItem];
        
        if (shouldPop) {
            if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
                if (![[self delegate] navigationBar:self shouldPopItem:currentItem]) {
                    return;
                }
            }
        }
        else {
            if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPushItem:)]) {
                if (![[self delegate] navigationBar:self shouldPushItem:newItem]) {
                    return;
                }
            }
        }
        
        [self willChangeValueForKey:@"items"];
        [_items setArray:items];
        [self didChangeValueForKey:@"items"];
        
        if (currentItem != nil) {
            [self performDisappearanceAnimationsForNavigationItem:currentItem backItem:backItem direction:(shouldPop ? PXNavigationDirectionPop : PXNavigationDirectionPush) animated:isAnimated];
        }
        
        if (newItem != nil) {
            [self performAppearanceAnimationsForNavigationItem:newItem backItem:newBackItem direction:(shouldPop ? PXNavigationDirectionPop : PXNavigationDirectionPush) animated:isAnimated];
        }
        
        if (shouldPop) {
            if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopItem:)]) {
                [[self delegate] navigationBar:self didPopItem:currentItem];
            }
        }
        else {
            if ([[self delegate] respondsToSelector:@selector(navigationBar:didPushItem:)]) {
                [[self delegate] navigationBar:self didPushItem:newItem];
            }
        }
    }
}

- (void)pushNavigationItem:(PXNavigationItem *)item animated:(BOOL)isAnimated {
    if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPushItem:)]) {
        if (![[self delegate] navigationBar:self shouldPushItem:item]) {
            return;
        }
    }
    
    PXNavigationItem *currentItem = [self topItem];
    PXNavigationItem *backItem = [self backItem];
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([_items count], 1)];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"items"];
    [_items addObject:item];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"items"];
    
    if (currentItem != nil) {
        [self performDisappearanceAnimationsForNavigationItem:currentItem backItem:backItem direction:PXNavigationDirectionPush animated:isAnimated];
    }
    
    if (item != nil) {
        [self performAppearanceAnimationsForNavigationItem:item backItem:currentItem direction:PXNavigationDirectionPush animated:isAnimated];
    }
        
    if ([[self delegate] respondsToSelector:@selector(navigationBar:didPushItem:)]) {
        [[self delegate] navigationBar:self didPushItem:item];
    }
}

- (void)popToNavigationItem:(PXNavigationItem *)item animated:(BOOL)isAnimated {
    NSUInteger index = [_items indexOfObjectIdenticalTo:item];
    if ([_items count] > 1 && index < [_items count]-1) {
        PXNavigationItem *currentItem = [self topItem];
        PXNavigationItem *backItem = [self backItem];
        
        PXNavigationItem *newBackItem = (index > 0 ? [_items objectAtIndex:(index - 1)] : nil);
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopItem:currentItem]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, [_items count]-(index+1))];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectsInRange:NSMakeRange(index+1, [_items count]-(index+1))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if (currentItem != nil) {
            [self performDisappearanceAnimationsForNavigationItem:currentItem backItem:backItem direction:PXNavigationDirectionPop animated:isAnimated];
        }
        
        if (item != nil) {
            [self performAppearanceAnimationsForNavigationItem:item backItem:newBackItem direction:PXNavigationDirectionPop animated:isAnimated];
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopItem:)]) {
            [[self delegate] navigationBar:self didPopItem:currentItem];
        }
    }
}

- (void)popToRootNavigationItemAnimated:(BOOL)isAnimated {
    if ([_items count] > 1) {
        PXNavigationItem *currentItem = [self topItem];
        PXNavigationItem *backItem = [self backItem];
        
        PXNavigationItem *newItem = [_items objectAtIndex:0];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopItem:currentItem]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [_items count] - 2)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectsInRange:NSMakeRange(1, [_items count]-2)];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if (currentItem != nil) {
            [self performDisappearanceAnimationsForNavigationItem:currentItem backItem:backItem direction:PXNavigationDirectionPop animated:isAnimated];
        }
        
        if (newItem != nil) {
            [self performAppearanceAnimationsForNavigationItem:newItem backItem:nil direction:PXNavigationDirectionPop animated:isAnimated];
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopItem:)]) {
            [[self delegate] navigationBar:self didPopItem:currentItem];
        }
    }
}

- (void)popNavigationItemAnimated:(BOOL)isAnimated {
    if ([_items count] > 1) {
        PXNavigationItem *currentItem = [self topItem];
        PXNavigationItem *backItem = [self backItem];
        NSUInteger index = [_items indexOfObjectIdenticalTo:backItem];
        PXNavigationItem *newBackItem = (index > 0 ? [_items objectAtIndex:(index - 1)] : nil);
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopItem:currentItem]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([_items count] - 1, 1)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectAtIndex:[_items count]-1];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if (currentItem != nil) {
            [self performDisappearanceAnimationsForNavigationItem:currentItem backItem:backItem direction:PXNavigationDirectionPop animated:isAnimated];
        }
        
        if (backItem != nil) {
            [self performAppearanceAnimationsForNavigationItem:backItem backItem:newBackItem direction:PXNavigationDirectionPop animated:isAnimated];
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopItem:)]) {
            [[self delegate] navigationBar:self didPopItem:currentItem];
        }
    }
}

@end
