//
//  PXPreferencesController.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PXViewController;


/*!
 * @class PXPreferencesController
 * @abstract A preferences window controller
 * 
 * @discussion
 * The controller manages a series of panes that are displayed as a preferences window.
 */
@interface PXPreferencesController : NSWindowController

/*!
 * @method sharedController
 * @abstract Gets the default preferences controller
 * 
 * @result A PXPreferencesController object
 */
+ (PXPreferencesController *)defaultController;

/*!
 * @property autosaveIdentifier
 * @abstract Gets the autosave identifier for the preference pane
 * 
 * @result An NSString object
 */
@property (copy) NSString *autosaveIdentifier;

/*!
 * @property preferencePanes
 * @abstract Gets the array of preference panes.
 * 
 * @discussion
 * Observable via KVO.
 * 
 * @result An NSArray of PXViewController objects
 */
@property (strong, readonly) NSArray *preferencePanes;

/*!
 * @property currentPreferencePane
 * @abstract Gets the current preference pane.
 * 
 * @discussion
 * Observable via KVO.
 * 
 * @result A PXViewController object
 */
@property (strong, readonly) PXViewController *currentPreferencePane;

/*!
 * @method preferencePaneWithIdentifier:
 * @abstract Gets the preference pane with a specific identifier (or nil if none exists)
 * 
 * @param identifier
 * The identifier of the preference pane to get
 * 
 * @result A PXViewController object
 */
- (PXViewController *)preferencePaneWithIdentifier:(NSString *)identifier;

/*!
 * @method preferencePaneAtIndex:
 * @abstract Gets the preference pane at a specific index
 * 
 * @param index
 * The index of the preference pane to get
 * 
 * @result A PXViewController object
 */
- (PXViewController *)preferencePaneAtIndex:(NSUInteger)index;

/*!
 * @method addPreferencePane:
 * @abstract Append a preference pane to the receiver
 * 
 * @param preferencePane
 * The preference pane to add
 */
- (void)addPreferencePane:(PXViewController *)preferencePane;

/*!
 * @method insertPreferencePane:atIndex:
 * @abstract Append a preference pane to the receiver
 * 
 * @param preferencePane
 * The preference pane to insert
 * 
 * @param index
 * The index at which to insert the preference pane
 */
- (void)insertPreferencePane:(PXViewController *)preferencePane atIndex:(NSUInteger)index;

/*!
 * @method removePreferencePaneAtIndex:
 * @abstract Removes the preference pane at a specified index from the receiver
 * 
 * @param index
 * The index of the preference pane to remove
 */
- (void)removePreferencePaneAtIndex:(NSUInteger)index;

/*!
 * @method removePreferencePane:
 * @abstract Removes a specified preference pane from the receiver
 * 
 * @param preferencePane
 * The preference pane to remove
 */
- (void)removePreferencePane:(PXViewController *)preferencePane;

/*!
 * @method showPreferencePaneWithIdentifier:
 * @abstract Switch to the preference pane with a specified identifier
 * 
 * @param identifier
 * The identifier of the pane to which to switch
 */
- (void)showPreferencePaneWithIdentifier:(NSString *)identifier;

@end
