//
//  PXPreferencesController.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PXPreferencePane;


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
 * @abstract The shared instance
 * 
 * @result A global PXPreferencesController object
 */
+ (PXPreferencesController *)sharedController;

/*!
 * @method init
 * @abstract Create a new instance
 * 
 * @result A new PXPreferencesController object
 */
- (id)init;

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
 * @result An NSArray of PXPreferencePane objects
 */
@property (strong, readonly) NSArray *preferencePanes;

/*!
 * @property currentPreferencePane
 * @abstract Gets the current preference pane.
 * 
 * @discussion
 * Observable via KVO.
 * 
 * @result A PXPreferencePane object
 */
@property (strong, readonly) PXPreferencePane *currentPreferencePane;

/*!
 * @method preferencePaneWithIdentifier:
 * @abstract Gets the preference pane with a specific identifier (or nil if none exists)
 * 
 * @param identifier
 * The identifier of the preference pane to get
 * 
 * @result A PXPreferencePane object
 */
- (PXPreferencePane *)preferencePaneWithIdentifier:(NSString *)identifier;

/*!
 * @method preferencePaneAtIndex:
 * @abstract Gets the preference pane at a specific index
 * 
 * @param index
 * The index of the preference pane to get
 * 
 * @result A PXPreferencePane object
 */
- (PXPreferencePane *)preferencePaneAtIndex:(NSUInteger)index;

/*!
 * @method addPreferencePane:
 * @abstract Append a preference pane to the receiver
 * 
 * @param preferencePane
 * The preference pane to add
 */
- (void)addPreferencePane:(PXPreferencePane *)preferencePane;

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
- (void)insertPreferencePane:(PXPreferencePane *)preferencePane atIndex:(NSUInteger)index;

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
- (void)removePreferencePane:(PXPreferencePane *)preferencePane;

/*!
 * @method showPreferencePaneWithIdentifier:
 * @abstract Switch to the preference pane with a specified identifier
 * 
 * @param identifier
 * The identifier of the pane to which to switch
 */
- (void)showPreferencePaneWithIdentifier:(NSString *)identifier;

@end
