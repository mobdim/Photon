//
//  PXPreferencesController.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXPreferencesController.h"
#import "PXPreferencesController_Private.h"

#import <QuartzCore/QuartzCore.h>


@interface PXPreferencesContainerView : NSView

@end


@implementation PXPreferencesController {
    PXPreferencesWindow *_window;
    PXPreferencesContainerView *_containerView;
    
    NSMutableArray *_preferencePaneIdentifiers;
    NSMutableDictionary *_preferencePanes;
    NSMutableDictionary *_toolbarItems;
    
    PXPreferencePane *_currentPane;
    PXPreferencePane *_disappearingPane;
    BOOL _animating;
    
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
        
        _containerView = [[PXPreferencesContainerView alloc] initWithFrame:[[_window contentView] bounds]];
        _containerView.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
        
        [[_window contentView] addSubview:_containerView];
        
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
    [_currentPane removeObserver:self forKeyPath:@"resizable"];
    [_currentPane removeObserver:self forKeyPath:@"minSize"];
    [_currentPane removeObserver:self forKeyPath:@"maxSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == _currentPane && [keyPath isEqualToString:@"view"]) {
        [self showPreferencePaneWithIdentifier:[_currentPane identifier]];
    }
    else if ((object == _currentPane && [keyPath isEqualToString:@"resizable"])
             || (object == _currentPane && [keyPath isEqualToString:@"minSize"])
             || (object == _currentPane && [keyPath isEqualToString:@"maxSize"])) {
        [self adjustWindowResizing];
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
        NSString *autosaveIdentifier = self.autosaveIdentifier;
        
        NSString *toolbarIdentifier = autosaveIdentifier;
        if (toolbarIdentifier == nil) {
            toolbarIdentifier = [[NSUUID UUID] UUIDString];
        }
        _toolbar = [[NSToolbar alloc] initWithIdentifier:toolbarIdentifier];
        [_toolbar setDelegate:self];
        [_toolbar setAllowsUserCustomization:NO];
        [_toolbar setAutosavesConfiguration:NO];
        [_window setToolbar:_toolbar];
        
        NSString *identifier = nil;
        if (autosaveIdentifier != nil) {
            NSString *selectedPanePreferenceKey = [NSString stringWithFormat:@"%@:SelectedPaneIdentifier", autosaveIdentifier];
            identifier = [[NSUserDefaults standardUserDefaults] stringForKey:selectedPanePreferenceKey];
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

- (void)adjustWindowResizing {
    BOOL resizable = _currentPane.resizable;
    if (resizable) {
        [self.window setStyleMask:(NSTitledWindowMask|NSClosableWindowMask|NSResizableWindowMask)];
        
        NSSize minSize = _currentPane.minSize;
        if (minSize.width == 0 || minSize.height == 0) {
            minSize = [_currentPane.view frame].size;
        }
        
        NSSize maxSize = _currentPane.maxSize;
        if (maxSize.width == 0 || maxSize.height == 0) {
            maxSize = [_currentPane.view frame].size;
        }
        
        [self.window setContentMinSize:minSize];
        [self.window setContentMaxSize:maxSize];
    }
    else {
        [self.window setStyleMask:(NSTitledWindowMask|NSClosableWindowMask)];
        
        [self.window setContentMinSize:NSZeroSize];
        [self.window setContentMaxSize:NSZeroSize];
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
    if (_animating) {
        [_toolbar setSelectedItemIdentifier:_currentPane.identifier];
        return;
    }
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
    PXPreferencePane *oldPane = _currentPane;
    PXPreferencePane *newPane = [_preferencePanes objectForKey:identifier];
    
    if (oldPane == newPane) {
        return;
    }
    
    [self willChangeValueForKey:@"currentPane"];
    
    [_currentPane removeObserver:self forKeyPath:@"view"];
    [_currentPane removeObserver:self forKeyPath:@"resizable"];
    [_currentPane removeObserver:self forKeyPath:@"minSize"];
    [_currentPane removeObserver:self forKeyPath:@"maxSize"];
    
    [self.window setContentMinSize:NSZeroSize];
    [self.window setContentMaxSize:NSZeroSize];
    
    _disappearingPane = oldPane;
    _currentPane = newPane;
    
    NSView *newView = [[_preferencePanes objectForKey:identifier] view];
    NSView *oldView = [[_containerView subviews] lastObject];
    
//    [_disappearingPane viewWillDisappear:shouldAnimate];
//    [_currentPane viewWillAppear:shouldAnimate];
    
    if (![newView isEqual:oldView]) {
        newView.frame = newView.bounds;
        
        oldView.autoresizingMask = (NSViewMaxYMargin|NSViewMaxXMargin);
        newView.autoresizingMask = (NSViewMaxYMargin|NSViewMaxXMargin);
        
        [oldPane setNextResponder:nil];
        [newPane setNextResponder:_window];
        
        NSRect newFrame = [self frameForView:newView];
        
        if (shouldAnimate) {
            [_containerView addSubview:newView];
            
            [newView setAlphaValue:0.0];
            
            _animating = YES;
            
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:0.25];
            
//            [[self window] setFrame:newFrame display:YES animate:YES];
            [[[self window] animator] setFrame:newFrame display:YES];
            [[oldView animator] setAlphaValue:0.0];
            [[newView animator] setAlphaValue:1.0];
            
            [NSAnimationContext endGrouping];
        }
        else {
            if (newView != nil) {
                [_containerView setSubviews:@[newView]];
            }
            else {
                [_containerView setSubviews:@[]];
            }
            [[self window] setFrame:newFrame display:YES];
            
            [self adjustWindowResizing];
            _currentPane.view.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
            [[self window] makeFirstResponder:[[_currentPane view] nextKeyView]];
            
//            [_disappearingPane viewDidDisappear:shouldAnimate];
//            [_currentPane viewDidAppear:shouldAnimate];
        }
    }
    
    [[self window] setTitle:[[_toolbarItems objectForKey:identifier] label]];
    [_toolbar setSelectedItemIdentifier:[_currentPane identifier]];
    
    [_currentPane addObserver:self forKeyPath:@"view" options:(NSKeyValueObservingOptionNew) context:nil];
    [_currentPane addObserver:self forKeyPath:@"resizable" options:(NSKeyValueObservingOptionNew) context:nil];
    [_currentPane addObserver:self forKeyPath:@"minSize" options:(NSKeyValueObservingOptionNew) context:nil];
    [_currentPane addObserver:self forKeyPath:@"maxSize" options:(NSKeyValueObservingOptionNew) context:nil];
    
    NSString *autosaveIdentifier = self.autosaveIdentifier;
    if (autosaveIdentifier != nil) {
        NSString *selectedPanePreferenceKey = [NSString stringWithFormat:@"%@:SelectedPaneIdentifier", autosaveIdentifier];
        [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:selectedPanePreferenceKey];
    }
    
    [self didChangeValueForKey:@"currentPane"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if ([[_containerView subviews] count] > 1) {
        NSView *subview = nil;
        
        NSEnumerator *subviewsEnum = [[_containerView subviews] reverseObjectEnumerator];
        [subviewsEnum nextObject];
        
        while ((subview = [subviewsEnum nextObject]) != nil) {
            [subview removeFromSuperviewWithoutNeedingDisplay];
            [subview setAlphaValue:1.0];
        }
        
//        [_disappearingPane viewDidDisappear:YES];
//        [_currentPane viewDidAppear:YES];
        
        if (flag) {
            _animating = NO;
            [self adjustWindowResizing];
            _currentPane.view.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
            [[self window] makeFirstResponder:_currentPane.view.nextKeyView];
            [_containerView setNeedsDisplay:YES];
        }
    }
}

- (NSRect)frameForView:(NSView *)view {
    NSRect frameRect = [[self window] frameRectForContentRect:[view bounds]];
    frameRect.origin.x = [[self window] frame].origin.x;
    frameRect.origin.y = NSMaxY([[self window] frame]) - NSHeight(frameRect);
    return frameRect;
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


@implementation PXPreferencesContainerView

- (BOOL)isOpaque {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor windowBackgroundColor] set];
    NSRectFillUsingOperation([self bounds], NSCompositeSourceOver);
}

@end
