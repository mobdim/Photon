//
//  PXPreferencesController.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXPreferencesController.h"
#import "PXPreferencesController_Private.h"
#import "PXViewController.h"

#import <QuartzCore/QuartzCore.h>


@implementation PXPreferencesController {
    PXPreferencesWindow *_window;
    NSMutableArray *_preferencePaneIdentifiers;
    NSMutableDictionary *_preferencePanes;
    NSMutableDictionary *_toolbarItems;
    
    PXPreferencePane *_currentPane;
    PXPreferencePane *_disappearingPane;
    
    NSToolbar *_toolbar;
}

+ (PXPreferencesController *)defaultController {
    static __strong PXPreferencesController *defaultController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultController = [[self alloc] init];
    });
    return defaultController;
}

- (id)init {
    self = [super init];
    if (self) {
        _window = [[PXPreferencesWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 510.0, 240.0) styleMask:(NSTitledWindowMask|NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
        [_window setDelegate:self];
        [_window setHidesOnDeactivate:NO];
        [_window setShowsToolbarButton:NO];
        [_window setReleasedWhenClosed:NO];
        [_window setNextResponder:self];
        [self setNextResponder:[NSApplication sharedApplication]];
        
        _currentPane = nil;
        _preferencePaneIdentifiers = [[NSMutableArray alloc] init];
        _preferencePanes = [[NSMutableDictionary alloc] init];
        _toolbarItems = [[NSMutableDictionary alloc] init];
        
        CAAnimation *animation = [CABasicAnimation animation];
        animation.duration = 0.2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [animation setDelegate:self];
        [_window setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frame"]];
    }
    return self;
}

- (void)dealloc {
    [_currentPane removeObserver:self forKeyPath:@"view"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"view"]) {
        [self showPreferencePaneWithIdentifier:[_currentPane identifier]];
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSWindow *)window {
    return _window;
}

- (IBAction)showWindow:(id)sender {
    BOOL visible = [[self window] isVisible];
    if (!visible) {
        [[self window] center];
    }
    
    if (_toolbar == nil) {
        if (self.autosaveIdentifier == nil) {
            self.autosaveIdentifier = @"PXPreferencesToolbar";
        }
        _toolbar = [[NSToolbar alloc] initWithIdentifier:self.autosaveIdentifier];
        [_toolbar setDelegate:self];
        [_toolbar setAllowsUserCustomization:NO];
        [_toolbar setAutosavesConfiguration:NO];
        [_window setToolbar:_toolbar];
        
        NSString *identifier = nil;
        if ([self autosaveIdentifier] != nil) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            identifier = [defaults stringForKey:[self autosaveIdentifier]];
            if ([self preferencePaneWithIdentifier:identifier] == nil) {
                identifier = nil;
            }
        }
        if (identifier == nil && [_preferencePaneIdentifiers count] > 0) {
            identifier = [_preferencePaneIdentifiers objectAtIndex:0];
        }
        
        if (identifier != nil) {
            [[[self window] toolbar] setSelectedItemIdentifier:identifier];
            [self showPreferencePaneWithIdentifier:identifier animate:NO];
        }
    }
    
    [[self window] makeKeyAndOrderFront:nil];
    
    if (_currentPane != nil) {
        [[self window] makeFirstResponder:_currentPane.view.nextKeyView];
    }
}


#pragma mark -
#pragma mark Preference Panes

- (NSArray *)preferencePanes {
    return [_preferencePanes objectsForKeys:_preferencePaneIdentifiers notFoundMarker:[NSNull null]];
}

- (PXPreferencePane *)currentPreferencePane {
    return _currentPane;
}

- (void)addPreferencePane:(PXPreferencePane *)preferencePane {
    [self insertPreferencePane:preferencePane atIndex:[_preferencePaneIdentifiers count]];
}

- (void)insertPreferencePane:(PXPreferencePane *)preferencePane atIndex:(NSUInteger)index {
    NSString *identifier = [preferencePane identifier];
    
    if (![_preferencePaneIdentifiers containsObject:identifier]) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, 1)];
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"preferencePanes"];
        
        NSString *label = [preferencePane title];
        NSImage *image = [preferencePane image];
        
        [_preferencePaneIdentifiers insertObject:identifier atIndex:index];
        [_preferencePanes setObject:preferencePane forKey:identifier];
        
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        [item setLabel:label];
        [item setImage:image];
        [item setTarget:self];
        [item setAction:@selector(toggleActivePreferenceView:)];
        
        [_toolbarItems setObject:item forKey:identifier];
        
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"preferencePanes"];
    }
}

- (void)removePreferencePaneAtIndex:(NSUInteger)index {
    if ([_preferencePaneIdentifiers count] > index) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, 1)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"preferencePanes"];
        
        NSString *identifier = [_preferencePaneIdentifiers objectAtIndex:index];
        
        [_toolbarItems removeObjectForKey:identifier];
        [_preferencePanes removeObjectForKey:identifier];
        [_preferencePaneIdentifiers removeObject:identifier];
        
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"preferencePanes"];
    }
}

- (void)removePreferencePane:(PXPreferencePane *)preferencePane {
    NSString *identifier = [preferencePane identifier];
    NSUInteger index = [_preferencePaneIdentifiers indexOfObjectIdenticalTo:identifier];
    [self removePreferencePaneAtIndex:index];
}

- (PXPreferencePane *)preferencePaneWithIdentifier:(NSString *)identifier {
    return [_preferencePanes objectForKey:identifier];
}

- (PXPreferencePane *)preferencePaneAtIndex:(NSUInteger)index {
    return [_preferencePanes objectForKey:[_preferencePaneIdentifiers objectAtIndex:index]];
}

- (void)showPreferencePaneWithIdentifier:(NSString *)identifier {
    if (![[self window] isVisible]) {
        [self showWindow:self];
    }
    
    [self showPreferencePaneWithIdentifier:identifier animate:YES];
    [_toolbar setSelectedItemIdentifier:identifier];
}


#pragma mark -
#pragma mark Animation

- (void)toggleActivePreferenceView:(NSToolbarItem *)item {
    NSString *identifier = [item itemIdentifier];
    PXPreferencePane *oldPane = _currentPane;
    PXPreferencePane *newPane = [_preferencePanes objectForKey:identifier];
    [_toolbar setSelectedItemIdentifier:[_currentPane identifier]];
    if (oldPane != newPane) {
        [self showPreferencePaneWithIdentifier:identifier animate:YES];
    }
}

- (void)showPreferencePaneWithIdentifier:(NSString *)identifier animate:(BOOL)shouldAnimate {
    if (_currentPane != nil) {
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    identifier, @"identifier",
                                    [NSNumber numberWithBool:shouldAnimate], @"shouldAnimate",
                                    nil];
        [_currentPane commitEditingWithDelegate:self didCommitSelector:@selector(pane:didCommit:contextInfo:) contextInfo:(__bridge_retained void *)dictionary];
    }
    else {
        [self confirmedShowPreferencePaneWithIdentifier:identifier animate:shouldAnimate];
    }
}

- (void)pane:(PXPreferencePane *)pane didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo {
    NSDictionary *dictionary = (__bridge_transfer NSDictionary *)contextInfo;
    if (didCommit) {
        NSString *identifier = [dictionary objectForKey:@"identifier"];
        BOOL shouldAnimate = [[dictionary objectForKey:@"shouldAnimate"] boolValue];
        [self confirmedShowPreferencePaneWithIdentifier:identifier animate:shouldAnimate];
    }
    else {
        [_toolbar setSelectedItemIdentifier:[_currentPane identifier]];
    }
}

- (void)confirmedShowPreferencePaneWithIdentifier:(NSString *)identifier animate:(BOOL)shouldAnimate {
    [self willChangeValueForKey:@"currentPane"];
    
    PXPreferencePane *oldPane = _currentPane;
    PXPreferencePane *newPane = [_preferencePanes objectForKey:identifier];
    
    [_currentPane removeObserver:self forKeyPath:@"view"];
    
    NSView *newView = [[_preferencePanes objectForKey:identifier] view];
    NSView *oldView = [[[[self window] contentView] subviews] lastObject];
    
    _disappearingPane = oldPane;
    _currentPane = newPane;
    
    if (![newView isEqualTo:oldView]) {
        [newView setFrame:[newView bounds]];
        
        [oldView setAutoresizingMask:(NSViewMaxYMargin)];
        [newView setAutoresizingMask:(NSViewMaxYMargin)];
        
        [oldPane setNextResponder:nil];
        [newPane setNextResponder:_window];
        
        if (shouldAnimate) {
            [[[self window] contentView] addSubview:newView];
            
            [newView setAlphaValue:0.0];
            
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0.25];
            
            [[[self window] animator] setFrame:[self frameForView:newView] display:YES];
            [[oldView animator] setAlphaValue:0.0];
            [[newView animator] setAlphaValue:1.0];
            
            [NSAnimationContext endGrouping];
        }
        else {
            if (newView != nil) {
                [[[self window] contentView] setSubviews:[NSArray arrayWithObject:newView]];
            }
            else {
                [[[self window] contentView] setSubviews:[NSArray array]];
            }
            [[self window] setFrame:[self frameForView:newView] display:YES];
        }
    }
    
    [[self window] setTitle:[[_toolbarItems objectForKey:identifier] label]];
    [_toolbar setSelectedItemIdentifier:[_currentPane identifier]];
    
    [_currentPane addObserver:self forKeyPath:@"view" options:(NSKeyValueObservingOptionNew) context:nil];
    
    if ([self autosaveIdentifier] != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:identifier forKey:[self autosaveIdentifier]];
    }
    
    [self didChangeValueForKey:@"currentPane"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if ([[[[self window] contentView] subviews] count] > 1) {
        NSView *subview = nil;
        
        NSEnumerator *subviewsEnum = [[[[self window] contentView] subviews] reverseObjectEnumerator];
        [subviewsEnum nextObject];
        
        while ((subview = [subviewsEnum nextObject]) != nil) {
            [subview removeFromSuperviewWithoutNeedingDisplay];
            [subview setAlphaValue:1.0];
        }
        
        [[self window] makeFirstResponder:_currentPane.view.nextKeyView];
        [[[self window] contentView] setNeedsDisplay:YES];
    }
}

- (NSRect)frameForView:(NSView *)view {
    NSRect windowFrame = [[self window] frame];
    NSRect contentRect = [[self window] contentRectForFrameRect:windowFrame];
    CGFloat windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect);
    
    windowFrame.size.height = NSHeight([view frame]) + windowTitleAndToolbarHeight;
    windowFrame.size.width = NSWidth([view frame]);
    windowFrame.origin.y = NSMaxY([[self window] frame]) - NSHeight(windowFrame);
    
    return windowFrame;
}


#pragma mark -
#pragma mark Toolbar delegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [_toolbarItems objectForKey:itemIdentifier];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return _preferencePaneIdentifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return _preferencePaneIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    return _preferencePaneIdentifiers;
}


#pragma mark -
#pragma mark Window delegate

//- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
//    if ([_currentPane respondsToSelector:@selector(undoManager)]) {
//        return [_currentPane undoManager];
//    }
//    return nil;
//}

- (BOOL)windowShouldClose:(id)sender {
    if (_currentPane) {
        [_currentPane commitEditingWithDelegate:self didCommitSelector:@selector(pane:didCommitForClose:contextInfo:) contextInfo:nil];
        return NO;
    }
    return YES;
}

- (void)pane:(PXPreferencePane *)pane didCommitForClose:(BOOL)didCommit contextInfo:(void *)contextInfo {
    if (didCommit) {
        [_window close];
    }
}

@end


@implementation PXPreferencesWindow

- (void)cancelOperation:(id)sender {
    [self close];
}

@end
