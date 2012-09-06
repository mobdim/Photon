//
//  PXNavigationBar.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationBar.h"
#import "PXNavigationItem.h"


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
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopItem:)]) {
            [[self delegate] navigationBar:self didPopItem:currentItem];
        }
    }
}

@end
