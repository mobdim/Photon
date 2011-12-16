//
//  PXViewController.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PXNavigationController, PXNavigationItem;
@class PXTabBarController, PXTabBarItem;


/* PXViewController is a custom subclass of NSViewController that adds
 * many missing features from its iOS counterpart, such as support for
 * will/didAppear and will/didDisappear, navigation and tab bars
 */
@interface PXViewController : NSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil; // Designated initializer
- (id)initWithView:(NSView *)aView;


@property (copy, readwrite) NSString *title;
@property (copy, readwrite) NSImage *image;
@property (retain, readwrite) NSUndoManager *undoManager;

@property (weak, readonly) PXViewController *parentViewController;


- (void)viewDidLoad;
- (void)viewDidUnload; // Not currently invoked

- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;


// Navigation controller
@property (retain, readonly) PXNavigationController *navigationController;
@property (retain, readonly) PXNavigationItem *navigationItem;

// Tab Bar controller
@property (retain, readonly) PXTabBarController *tabBarController;
@property (retain, readonly) PXTabBarItem *tabBarItem;

@end
