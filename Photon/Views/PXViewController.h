//
//  PXViewController.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PXNavigationController, PXNavigationItem;
@class PXTabBarController, PXTabBarItem;


/*!
 * @class PXViewController
 * @abstract A basic subclass of NSViewController
 * 
 * @discussion
 * PXViewController adds many missing features from the iOS counterpart,
 * such as support for will/didAppear and will/didDisappear, navigation
 * and tab bars.
 */
@interface PXViewController : NSViewController

/*!
 * @method initWithNibName:bundle:
 * @abstract Creates a view controller from a nib/xib
 * 
 * @discussion
 * This is the designated initializer
 * 
 * @result A new PXViewController object
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil; // Designated initializer

/*!
 * @method initWithView:
 * @abstract Creates a view controller from a view
 * 
 * @discussion
 * This method calls -initWithNibName:bundle: with a nil value for both arguments
 * 
 * @result A new PXViewController object
 */
- (id)initWithView:(NSView *)aView;


/*!
 * @property title
 * @abstract Gets the title of the view controller
 * 
 * @result An NSString object
 */
@property (copy) NSString *title;

/*!
 * @property image
 * @abstract Gets the image of the view controller
 * 
 * @result An NSImage object
 */
@property (copy) NSImage *image;

/*!
 * @property undoManager
 * @abstract Gets the undo manager of the view controller
 * 
 * @result An NSUndoManager object
 */
@property (strong) NSUndoManager *undoManager;


/*!
 * @property parentViewController
 * @abstract Gets the parent of the view controller
 * 
 * @result A PXViewController object
 */
@property (readonly) PXViewController *parentViewController;


/*!
 * @method viewDidLoad
 * @abstract Called after the controller's view is first loaded
 */
- (void)viewDidLoad;

/*!
 * @method viewDidLoad
 * @abstract Called after the controller's view is unloaded
 */
- (void)viewDidUnload;

/*!
 * @method viewWillAppear
 * @abstract Called before the controller's view is displayed
 */
- (void)viewWillAppear;

/*!
 * @method viewWillAppear
 * @abstract Called after the controller's view is displayed
 */
- (void)viewDidAppear;

/*!
 * @method viewWillAppear
 * @abstract Called before the controller's view is hidden
 */
- (void)viewWillDisappear;

/*!
 * @method viewWillAppear
 * @abstract Called after the controller's view is hidden
 */
- (void)viewDidDisappear;


/*!
 * @property navigationController
 * @abstract Gets the navigation controller containing the receiver
 * 
 * @result A PXNavigationController object
 */
@property (strong, readonly) PXNavigationController *navigationController;

/*!
 * @property navigationItem
 * @abstract Gets the navigation item representing the receiver
 * 
 * @result A PXNavigationItem object
 */
@property (strong, readonly) PXNavigationItem *navigationItem;


/*!
 * @property tabBarController
 * @abstract Gets the tab bar controller containing the receiver
 * 
 * @result A PXTabBarController object
 */
@property (strong, readonly) PXTabBarController *tabBarController;

/*!
 * @property tabBarItem
 * @abstract Gets the tab bar item representing the receiver
 * 
 * @result A PXTabBarItem object
 */
@property (strong, readonly) PXTabBarItem *tabBarItem;

@end
