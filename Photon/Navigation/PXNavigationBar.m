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
    NSMutableArray *items;
    NSPathControl *pathControl;
}

@synthesize delegate;

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        items = [[NSMutableArray alloc] init];
        
        pathControl = [[NSPathControl alloc] initWithFrame:NSMakeRect(0.0, 0.0, frameRect.size.width, frameRect.size.height)];
        [pathControl setAutoresizingMask:(NSViewWidthSizable|NSViewMinYMargin|NSViewMaxYMargin)];
        
        PXNavigationPathCell *pathCell = [[PXNavigationPathCell alloc] initTextCell:@"/"];
        [pathCell setPathStyle:NSPathStyleNavigationBar];
        [pathCell setControlSize:NSSmallControlSize];
        [pathCell setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        [pathControl setCell:pathCell];
        
        [pathControl setFocusRingType:NSFocusRingTypeNone];
        [pathControl setTarget:self];
        [pathControl setAction:@selector(pathControlAction:)];
        
        self.gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]
                                                      endingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]];
        self.inactiveGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0]
                                                              endingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]];
        self.hasTopBorder = NO;
        self.hasBottomBorder = YES;
        self.bottomBorderColor = [NSColor colorWithCalibratedWhite:0.6 alpha:1.0];
        self.inactiveBottomBorderColor = [NSColor colorWithCalibratedWhite:0.8 alpha:1.0];
        
        [self addSubview:pathControl];
        
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
    
    for (PXNavigationItem *item in items) {
        NSString *title = [item title];
        if (title == nil) {
            title = @"Untitled";
        }
        
        PXNavigationPathComponentCell *cell = [[PXNavigationPathComponentCell alloc] initTextCell:title];
        [cell setRepresentedObject:item];
        [cell setImage:[item image]];
        
        if ([items objectAtIndex:0] == item)
            cell.firstItem = YES;
        if ([items lastObject] == item)
            cell.lastItem = YES;
        
        [cells addObject:cell];
    }
    
    [pathControl setPathComponentCells:cells];
}


#pragma mark -
#pragma mark Items

- (NSArray *)items {
    return [items copy];
}

- (void)setItems:(NSArray *)newItems {
    if (![items isEqualToArray:newItems]) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [items count])];
        [self willChange:NSKeyValueChangeSetting valuesAtIndexes:indexes forKey:@"items"];
        [items setArray:newItems];
        [self didChange:NSKeyValueChangeSetting valuesAtIndexes:indexes forKey:@"items"];
    }
}

- (PXNavigationItem *)topItem {
    return [items lastObject];
}

- (void)pushNavigationItem:(PXNavigationItem *)item {
    if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPushItem:)]) {
        if (![[self delegate] navigationBar:self shouldPushItem:item]) {
            return;
        }
    }
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([items count], 1)];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"items"];
    [items addObject:item];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"items"];
    
    if ([[self delegate] respondsToSelector:@selector(navigationBar:didPushItem:)]) {
        [[self delegate] navigationBar:self didPushItem:item];
    }
}

- (void)popToNavigationItem:(PXNavigationItem *)item {
    NSUInteger index = [items indexOfObjectIdenticalTo:item];
    if ([items count] > 1 && index < [items count]-1) {
        PXNavigationItem *item = [items objectAtIndex:index];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopToItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopToItem:item]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index+1, [items count]-(index+1))];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [items removeObjectsInRange:NSMakeRange(index+1, [items count]-(index+1))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopToItem:)]) {
            [[self delegate] navigationBar:self didPopToItem:item];
        }
    }
}

- (void)popToRootNavigationItem {
    if ([items count] > 1) {
        PXNavigationItem *item = [items objectAtIndex:0];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopToItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopToItem:item]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, [items count]-2)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [items removeObjectsInRange:NSMakeRange(1, [items count]-2)];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopToItem:)]) {
            [[self delegate] navigationBar:self didPopToItem:item];
        }
    }
}

- (void)popNavigationItem {
    if ([items count] > 1) {
        PXNavigationItem *item = [items lastObject];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:shouldPopToItem:)]) {
            if (![[self delegate] navigationBar:self shouldPopToItem:item]) {
                return;
            }
        }
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([items count]-1, 1)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        [items removeObjectAtIndex:[items count]-1];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"items"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationBar:didPopToItem:)]) {
            [[self delegate] navigationBar:self didPopToItem:item];
        }
    }
}

@end
