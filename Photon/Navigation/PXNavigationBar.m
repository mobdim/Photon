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


@implementation PXNavigationBar {
    NSMutableArray *_items;
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

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)positionViewsAnimated:(BOOL)isAnimated {
    for (NSView *view in [[self subviews] copy]) {
        [view removeFromSuperview];
    }
    [self removeConstraints:[self constraints]];
    
    
    PXNavigationItem *backItem = [self backItem];
    PXNavigationItem *navigationItem = [self topItem];
    NSRect bounds = [self bounds];
    
    
    // Back button
    NSButton *backButton = [backItem backButton];
    if (backButton != nil) {
        [backButton sizeToFit];
        
        [backButton setTarget:self];
        [backButton setAction:@selector(popAction:)];
        
        [backButton setFrameOrigin:NSMakePoint(6.0, 2.0)];
        [backButton setContentCompressionResistancePriority:750.0 forOrientation:NSLayoutConstraintOrientationHorizontal];
        [self addSubview:backButton];
        
        [self addConstraints:@[
         [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:2.0],
         [NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:2.0],
        ]];
    }
    
    // Right accessory view
    PXBarButtonItem *rightBarButtonItem = [navigationItem rightBarButtonItem];
    NSButton *rightButton = nil;
    if (rightBarButtonItem != nil) {
        rightButton = [navigationItem rightButton];
        if (rightButton != nil) {
            [rightButton sizeToFit];
            
            [rightButton setTarget:[rightBarButtonItem target]];
            [rightButton setAction:[rightBarButtonItem action]];
            
            [rightButton setFrameOrigin:NSMakePoint(NSMaxX(bounds) - ([rightButton frame].size.width + 6.0), 2.0)];
            [rightButton setContentCompressionResistancePriority:750.0 forOrientation:NSLayoutConstraintOrientationHorizontal];
            [self addSubview:rightButton];
            
            [self addConstraints:@[
             [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:rightButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:2.0],
             [NSLayoutConstraint constraintWithItem:rightButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:2.0],
             ]];
        }
    }
    
    // Title View
    id titleView = [navigationItem titleView];
    if (titleView == nil) {
        titleView = [navigationItem titleField];
        [titleView setFont:[NSFont systemFontOfSize:12.0]];
        [titleView setTextColor:[NSColor colorWithCalibratedWhite:0.5 alpha:1.0]];
        [titleView setAlignment:NSCenterTextAlignment];
        [titleView setContentCompressionResistancePriority:250.0 forOrientation:NSLayoutConstraintOrientationHorizontal];
        [[titleView cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
    }
    
    if ([titleView respondsToSelector:@selector(sizeToFit)]) {
        [titleView sizeToFit];
    }
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    // Center
    NSLayoutConstraint *centeringConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    [centeringConstraint setPriority:750];
    [constraints addObject:centeringConstraint];
    
    // Leading
    if (backButton != nil) {
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:backButton attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
        [constraints addObject:leadingConstraint];
    }
    else {
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:2.0];
        [constraints addObject:leadingConstraint];
    }
    
    // Trailing
    if (rightButton != nil) {
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:rightButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:titleView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0];
        [constraints addObject:trailingConstraint];
    }
    else {
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:2.0];
        [constraints addObject:trailingConstraint];
    }
    
    // Top
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.0];
    [constraints addObject:topConstraint];
    
    [self addSubview:titleView];
    [self addConstraints:constraints];
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
        BOOL shouldPop = (newItem != nil ? [_items containsObject:newItem] : YES);
        PXNavigationItem *currentItem = [self topItem];
        
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
        
        [self positionViewsAnimated:isAnimated];
        
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
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([_items count], 1)];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"items"];
    [_items addObject:item];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"items"];
    
    [self positionViewsAnimated:isAnimated];
    
    if ([[self delegate] respondsToSelector:@selector(navigationBar:didPushItem:)]) {
        [[self delegate] navigationBar:self didPushItem:item];
    }
}

- (void)popToNavigationItem:(PXNavigationItem *)item animated:(BOOL)isAnimated {
    NSUInteger index = [_items indexOfObjectIdenticalTo:item];
    if ([_items count] > 1 && index < [_items count]-1) {
        PXNavigationItem *currentItem = [self topItem];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopItem:currentItem]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, [_items count]-(index+1))];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectsInRange:NSMakeRange(index+1, [_items count]-(index+1))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        [self positionViewsAnimated:isAnimated];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopItem:)]) {
            [[self delegate] navigationBar:self didPopItem:currentItem];
        }
    }
}

- (void)popToRootNavigationItemAnimated:(BOOL)isAnimated {
    if ([_items count] > 1) {
        PXNavigationItem *currentItem = [self topItem];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopItem:currentItem]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [_items count] - 2)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectsInRange:NSMakeRange(1, [_items count]-2)];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        [self positionViewsAnimated:isAnimated];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopItem:)]) {
            [[self delegate] navigationBar:self didPopItem:currentItem];
        }
    }
}

- (void)popNavigationItemAnimated:(BOOL)isAnimated {
    if ([_items count] > 1) {
        PXNavigationItem *currentItem = [self topItem];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopItem:currentItem]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([_items count] - 1, 1)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectAtIndex:[_items count]-1];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        [self positionViewsAnimated:isAnimated];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopItem:)]) {
            [[self delegate] navigationBar:self didPopItem:currentItem];
        }
    }
}

@end
