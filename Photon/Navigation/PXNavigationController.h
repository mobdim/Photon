//
//  PXNavigationController.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PXViewController.h>
#import <Photon/PXNavigationBar.h>


@class PXNavigationBar;
@protocol PXNavigationControllerDelegate;


/*!
 * @class PXNavigationController
 * @abstract Coordinates a stack of view controllers
 */
@interface PXNavigationController : PXViewController <PXNavigationBarDelegate>

- (id)initWithRootViewController:(PXViewController *)viewController;

@property (nonatomic, readonly) PXNavigationBar *navigationBar;

@property (nonatomic, copy) NSArray *viewControllers;
- (void)setViewControllers:(NSArray *)array animated:(BOOL)isAnimated;

@property (nonatomic, strong, readonly) PXViewController *topViewController;

@property (nonatomic, weak) id <PXNavigationControllerDelegate> delegate;

@property (nonatomic) BOOL automaticallyHidesNavigationBar;
- (void)setAutomaticallyHidesNavigationBar:(BOOL)automaticallyHidesNavigationBar animated:(BOOL)isAnimated;

@property (nonatomic, getter=isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)isAnimated;

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
