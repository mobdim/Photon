//
//  PXPreferencesController.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PXPreferencePane;


/* PXPreferencesController is a simple preferences window controller
 * The controller manages a series of preference panes that are displayed for the user
 */
@interface PXPreferencesController : NSWindowController <NSWindowDelegate, NSToolbarDelegate>

// Shared global instance
+ (PXPreferencesController *)sharedController;

// Returns an array of current preference panes. Observable via KVO.
@property (readonly, retain) NSArray *preferencePanes;

// Returns the current preference pane. Observable via KVO.
@property (readonly, retain) PXPreferencePane *currentPreferencePane;

// Returns the preference pane with a specific identifier (or nil if none exists)
- (PXPreferencePane *)preferencePaneWithIdentifier:(NSString *)identifier;

// Returns the preference pane at a specific index
- (PXPreferencePane *)preferencePaneAtIndex:(NSUInteger)index;

// Insert and remove preference panes from the controller
- (void)addPreferencePane:(PXPreferencePane *)preferencePane;
- (void)insertPreferencePane:(PXPreferencePane *)preferencePane atIndex:(NSUInteger)index;
- (void)removePreferencePaneAtIndex:(NSUInteger)index;
- (void)removePreferencePane:(PXPreferencePane *)preferencePane;

// Switch to the preference pane with a specific identifier
- (void)showPreferencePaneWithIdentifier:(NSString *)identifier;

@end
