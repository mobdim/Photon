//
//  PXPreferencesController.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXPreferencesController.h"
#import "PXPreferencesController_Private.h"
#import "PXPreferencePane.h"

#import <QuartzCore/QuartzCore.h>


@implementation PXPreferencesController {
	NSMutableArray *preferencePaneIdentifiers;
	NSMutableDictionary *preferencePanes;
	NSMutableDictionary *toolbarItems;
	
	PXPreferencePane *currentPane;
	
	NSToolbar *toolbar;
}

@synthesize autosaveIdentifier=_autosaveIdentifier;

+ (PXPreferencesController *)sharedController {
    static __strong PXPreferencesController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc] init];
    });
	return sharedController;
}

- (id)init {
    NSPanel *window = [[NSPanel alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 510.0, 240.0) styleMask:(NSTitledWindowMask|NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
    [window setHidesOnDeactivate:NO];
    self = [self initWithWindow:window];
    if (self) {
        
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window {
	self = [super initWithWindow:window];
	if (self) {
		[window setDelegate:self];
		[window setShowsToolbarButton:NO];
		
		currentPane = nil;
		preferencePaneIdentifiers = [[NSMutableArray alloc] init];
		preferencePanes = [[NSMutableDictionary alloc] init];
		toolbarItems = [[NSMutableDictionary alloc] init];
		
		CAAnimation *animation = [CABasicAnimation animation];
		animation.duration = 0.2;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[animation setDelegate:self];
		[window setAnimations:[NSDictionary dictionaryWithObject:animation forKey:@"frame"]];
	}
	return self;
}

- (void)dealloc {
	[currentPane removeObserver:self forKeyPath:@"view"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"view"]) {
		[self showPreferencePaneWithIdentifier:[currentPane identifier]];
	}
	else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (IBAction)showWindow:(id)sender {
	if (![[self window] isVisible]) {
		[[self window] center];
	}
	
	if (toolbar == nil) {
		toolbar = [[NSToolbar alloc] initWithIdentifier:@"PXPreferencesToolbar"];
		[toolbar setDelegate:self];
		[[self window] setToolbar:toolbar];
		
		NSString *identifier = nil;
        if ([self autosaveIdentifier] != nil) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            identifier = [defaults stringForKey:[self autosaveIdentifier]];
        }
        if (identifier == nil) {
            identifier= [preferencePaneIdentifiers objectAtIndex:0];
        }
		[[[self window] toolbar] setSelectedItemIdentifier:identifier];
		[self showPreferencePaneWithIdentifier:identifier animate:NO];
	}
	
	[super showWindow:sender];
	[[self window] makeFirstResponder:nil];
}


#pragma mark -
#pragma mark Preference Panes

- (NSArray *)preferencePanes {
	return [preferencePanes objectsForKeys:preferencePaneIdentifiers notFoundMarker:[NSNull null]];
}

- (PXPreferencePane *)currentPreferencePane {
	return currentPane;
}

- (void)addPreferencePane:(PXPreferencePane *)preferencePane {
	[self insertPreferencePane:preferencePane atIndex:[preferencePaneIdentifiers count]];
}

- (void)insertPreferencePane:(PXPreferencePane *)preferencePane atIndex:(NSUInteger)index {
	NSString *identifier = [preferencePane identifier];
	
	if (![preferencePaneIdentifiers containsObject:identifier]) {
		NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, 1)];
		[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"preferencePanes"];
		
		NSString *label = [preferencePane title];
		NSImage *image = [preferencePane image];
		
		[preferencePaneIdentifiers insertObject:identifier atIndex:index];
		[preferencePanes setObject:preferencePane forKey:identifier];
		
		NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
		[item setLabel:label];
		[item setImage:image];
		[item setTarget:self];
		[item setAction:@selector(toggleActivePreferenceView:)];
		
		[toolbarItems setObject:item forKey:identifier];
		
		[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"preferencePanes"];
	}
}

- (void)removePreferencePaneAtIndex:(NSUInteger)index {
	if ([preferencePaneIdentifiers count] > index) {
		NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, 1)];
		[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"preferencePanes"];
		
		NSString *identifier = [preferencePaneIdentifiers objectAtIndex:index];
		
		[toolbarItems removeObjectForKey:identifier];
		[preferencePanes removeObjectForKey:identifier];
		[preferencePaneIdentifiers removeObject:identifier];
		
		[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"preferencePanes"];
	}
}

- (void)removePreferencePane:(PXPreferencePane *)preferencePane {
	NSString *identifier = [preferencePane identifier];
	NSUInteger index = [preferencePaneIdentifiers indexOfObjectIdenticalTo:identifier];
	[self removePreferencePaneAtIndex:index];
}

- (PXPreferencePane *)preferencePaneWithIdentifier:(NSString *)identifier {
	return [preferencePanes objectForKey:identifier];
}

- (PXPreferencePane *)preferencePaneAtIndex:(NSUInteger)index {
	return [preferencePanes objectForKey:[preferencePaneIdentifiers objectAtIndex:index]];
}

- (void)showPreferencePaneWithIdentifier:(NSString *)identifier {
	if (![[self window] isVisible]) {
		[self showWindow:self];
	}
	
	[self showPreferencePaneWithIdentifier:identifier animate:YES];
	[toolbar setSelectedItemIdentifier:identifier];
}


#pragma mark -
#pragma mark Animation

- (void)toggleActivePreferenceView:(NSToolbarItem *)item {
	NSString *identifier = [item itemIdentifier];
	PXPreferencePane *oldPane = currentPane;
	PXPreferencePane *newPane = [preferencePanes objectForKey:identifier];
	[toolbar setSelectedItemIdentifier:[currentPane identifier]];
	if (oldPane != newPane) {
		[self showPreferencePaneWithIdentifier:identifier animate:YES];
	}
}

- (void)showPreferencePaneWithIdentifier:(NSString *)identifier animate:(BOOL)shouldAnimate {
	if (currentPane) {
        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    identifier, @"identifier",
                                    [NSNumber numberWithBool:shouldAnimate], @"shouldAnimate",
                                    nil];
		[currentPane commitEditingWithDelegate:self didCommitSelector:@selector(pane:didCommit:contextInfo:) contextInfo:(__bridge_retained void *)dictionary];
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
		[toolbar setSelectedItemIdentifier:[currentPane identifier]];
	}
}

- (void)confirmedShowPreferencePaneWithIdentifier:(NSString *)identifier animate:(BOOL)shouldAnimate {
	[self willChangeValueForKey:@"currentPane"];
	
	PXPreferencePane *oldPane = currentPane;
	PXPreferencePane *newPane = [preferencePanes objectForKey:identifier];
	
	[currentPane removeObserver:self forKeyPath:@"view"];
	
	NSView *newView = [[preferencePanes objectForKey:identifier] view];
	NSView *oldView = [[[[self window] contentView] subviews] lastObject];
	
	if (![newView isEqualTo:oldView]) {
		[oldPane viewWillDisappear];
		[newPane viewWillAppear];
		
		[newView setFrame:[newView bounds]];
		
		[oldView setAutoresizingMask:(NSViewMaxYMargin)];
		[newView setAutoresizingMask:(NSViewMaxYMargin)];
		
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
			[[[self window] contentView] setSubviews:[NSArray arrayWithObject:newView]];
			[[self window] setFrame:[self frameForView:newView] display:YES];
		}
		
		[oldPane viewDidDisappear];
		[newPane viewDidAppear];
	}
	
	currentPane = newPane;
	
	[[self window] setTitle:[[toolbarItems objectForKey:identifier] label]];
	[toolbar setSelectedItemIdentifier:[currentPane identifier]];
	
	[currentPane addObserver:self forKeyPath:@"view" options:(NSKeyValueObservingOptionNew) context:nil];
    
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
		
		[[self window] makeFirstResponder:nil];
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
#pragma mark Toolbar Delegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	return [toolbarItems objectForKey:itemIdentifier];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	return preferencePaneIdentifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	return preferencePaneIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return preferencePaneIdentifiers;
}


#pragma mark -
#pragma mark Window Delegate

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
	if ([currentPane respondsToSelector:@selector(undoManager)]) {
		return [currentPane undoManager];
	}
	return nil;
}

- (void)changeFont:(id)sender {
    if ([currentPane respondsToSelector:@selector(changeFont:)]) {
        [currentPane changeFont:sender];
    }
}

- (BOOL)windowShouldClose:(id)sender {
	if (currentPane) {
		[currentPane commitEditingWithDelegate:self didCommitSelector:@selector(pane:didCommitForClose:contextInfo:) contextInfo:nil];
		return NO;
	}
	return YES;
}

- (void)pane:(PXPreferencePane *)pane didCommitForClose:(BOOL)didCommit contextInfo:(void *)contextInfo {
	if (didCommit) {
		[self close];
	}
}

@end
