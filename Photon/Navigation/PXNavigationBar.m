//
//  PXNavigationBar.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationBar.h"
#import "PXNavigationItem.h"
#import "PXNavigationPathCell.h"
#import "PXNavigationPathComponentCell.h"


@interface PXNavigationBar ()

- (void)rebuildPathComponentCells;

@end


@implementation PXNavigationBar {
    NSMutableArray *_items;
    NSPathControl *_pathControl;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        
        _pathControl = [[NSPathControl alloc] initWithFrame:NSMakeRect(0.0, 0.0, frameRect.size.width, frameRect.size.height)];
        [_pathControl setAutoresizingMask:(NSViewWidthSizable|NSViewMinYMargin|NSViewMaxYMargin)];
        
        PXNavigationPathCell *pathCell = [[PXNavigationPathCell alloc] initTextCell:@"/"];
        [pathCell setPathStyle:NSPathStyleNavigationBar];
        [pathCell setControlSize:NSSmallControlSize];
        [pathCell setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        [_pathControl setCell:pathCell];
        
        [_pathControl setFocusRingType:NSFocusRingTypeNone];
        [_pathControl setTarget:self];
        [_pathControl setAction:@selector(pathControlAction:)];
        
        self.style = PXNavigationBarStyleLight;
        
        [self addSubview:_pathControl];
        
        [self addObserver:self forKeyPath:@"items" options:(NSKeyValueObservingOptionInitial) context:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObserver:self forKeyPath:@"items"];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"items"]) {
        [self rebuildPathComponentCells];
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


#pragma mark -
#pragma mark Path Control

- (IBAction)pathControlAction:(NSPathControl *)sender {
    NSPathComponentCell *pathComponentCell = [[sender cell] clickedPathComponentCell];
    id object = [pathComponentCell representedObject];
    
    if ([object isKindOfClass:[PXNavigationItem class]]) {
        [self popToNavigationItem:(PXNavigationItem *)object];
    }
}

- (void)rebuildPathComponentCells {
    NSMutableArray *cells = [NSMutableArray array];
    
    for (PXNavigationItem *item in _items) {
        NSString *title = [item title];
        if (title == nil) {
            title = @"Untitled";
        }
        
        PXNavigationPathComponentCell *cell = [[PXNavigationPathComponentCell alloc] initTextCell:title];
        [cell setRepresentedObject:item];
        [cell setImage:[item image]];
        
        if ([_items objectAtIndex:0] == item)
            cell.firstItem = YES;
        if ([_items lastObject] == item)
            cell.lastItem = YES;
        
        [cells addObject:cell];
    }
    
    [_pathControl setPathComponentCells:cells];
}


#pragma mark -
#pragma mark Items

- (NSArray *)items {
    return [_items copy];
}

- (void)setItems:(NSArray *)newItems {
    if (![_items isEqualToArray:newItems]) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_items count])];
        [self willChange:NSKeyValueChangeSetting valuesAtIndexes:indexes forKey:@"items"];
        [_items setArray:newItems];
        [self didChange:NSKeyValueChangeSetting valuesAtIndexes:indexes forKey:@"items"];
    }
}

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

- (void)pushNavigationItem:(PXNavigationItem *)item {
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

- (void)popToNavigationItem:(PXNavigationItem *)item {
    NSUInteger index = [_items indexOfObjectIdenticalTo:item];
    if ([_items count] > 1 && index < [_items count]-1) {
        PXNavigationItem *item = [_items objectAtIndex:index];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopToItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopToItem:item]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, [_items count]-(index+1))];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectsInRange:NSMakeRange(index+1, [_items count]-(index+1))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopToItem:)]) {
            [[self delegate] navigationBar:self didPopToItem:item];
        }
    }
}

- (void)popToRootNavigationItem {
    if ([_items count] > 1) {
        PXNavigationItem *item = [_items objectAtIndex:0];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopToItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopToItem:item]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [_items count]-2)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectsInRange:NSMakeRange(1, [_items count]-2)];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopToItem:)]) {
            [[self delegate] navigationBar:self didPopToItem:item];
        }
    }
}

- (void)popNavigationItem {
    if ([_items count] > 1) {
        PXNavigationItem *item = [_items lastObject];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopToItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopToItem:item]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([_items count]-1, 1)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [_items removeObjectAtIndex:[_items count]-1];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopToItem:)]) {
            [[self delegate] navigationBar:self didPopToItem:item];
        }
    }
}

@end
