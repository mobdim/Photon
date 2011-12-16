//
//  PXNavigationController.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PXViewController.h>
#import <Photon/PXNavigationBar.h>


@class PXNavigationBar;
@protocol PXNavigationControllerDelegate;


/* PXNavigationController is an NSViewController subclass that manages
 * a stack of child view controllers, allowing navigation between them
 * similar to the UIKit's UIViewController.
 */
@interface PXNavigationController : PXViewController <PXNavigationBarDelegate, NSAnimationDelegate>

- (id)initWithRootViewController:(PXViewController *)viewController;

@property (assign) IBOutlet PXNavigationBar *navigationBar;

@property (copy) NSArray *viewControllers;
@property (strong, readonly) PXViewController *topViewController;

@property (weak) id <PXNavigationControllerDelegate> delegate;

@property (assign) BOOL alwaysShowsNavigationBar;

- (void)setViewControllers:(NSArray *)array animated:(BOOL)isAnimated;

- (void)pushViewController:(PXViewController *)viewController animated:(BOOL)isAnimated;
- (void)popViewControllerAnimated:(BOOL)isAnimated;
- (void)popToRootViewControllerAnimated:(BOOL)isAnimated;
- (void)popToViewController:(PXViewController *)viewController animated:(BOOL)isAnimated;

@end


@protocol PXNavigationControllerDelegate <NSObject>

@optional
- (void)navigationController:(PXNavigationController *)aNavigationController willShowViewController:(PXViewController *)viewController animated:(BOOL)isAnimated;
- (void)navigationController:(PXNavigationController *)aNavigationController didShowViewController:(PXViewController *)viewController animated:(BOOL)isAnimated;

- (void)navigationController:(PXNavigationController *)aNavigationController willPushViewController:(PXViewController *)viewController animated:(BOOL)isAnimated;
- (void)navigationController:(PXNavigationController *)aNavigationController didPushViewController:(PXViewController *)viewController animated:(BOOL)isAnimated;
- (void)navigationController:(PXNavigationController *)aNavigationController willPopViewController:(PXViewController *)viewController animated:(BOOL)isAnimated;
- (void)navigationController:(PXNavigationController *)aNavigationController didPopViewController:(PXViewController *)viewController animated:(BOOL)isAnimated;

@end
