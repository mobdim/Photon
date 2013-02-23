//
//  PXViewController.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*!
 * @category NSViewController(PXViewController)
 * @abstract Additions to NSViewController
 * 
 * @discussion
 * The PXViewController category adds many missing features from the iOS counterpart,
 * such as support for will/didAppear and will/didDisappear notifications.
 */
@interface NSViewController (PXViewController)

/*!
 * @method px_installViewControllerSupport
 * @abstract Enables support for extended view controllers
 * 
 * @discussion
 * Calling this method is required in order for view controllers
 * to participate in the responder chain, in appearance notifications, etc.
 */
+ (void)px_installViewControllerSupport;


/*!
 * @property parentViewController
 * @abstract The parent of the view controller
 * 
 * @result An NSViewController object
 */
@property (nonatomic, weak, readonly) NSViewController *parentViewController;

/*!
 * @property contentSizeForViewInPopover
 * @abstract The size required to display the receiver's content in a popover
 * 
 * @discussion
 * By default, this is set to 320.0 x 480.0.
 *
 * @result An NSSize value
 */
@property (nonatomic) NSSize contentSizeForViewInPopover;


/*!
 * @method viewWillAppear
 * @abstract Called before the controller's view appears
 */
- (void)viewWillAppear;

/*!
 * @method viewWillAppear
 * @abstract Called after the controller's view appears
 */
- (void)viewDidAppear;

/*!
 * @method viewWillAppear
 * @abstract Called before the controller's view disappears
 */
- (void)viewWillDisappear;

/*!
 * @method viewWillAppear
 * @abstract Called after the controller's view disappears
 */
- (void)viewDidDisappear;

@end
