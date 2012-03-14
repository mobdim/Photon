//
//  PXTabBarController.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PhotonDefines.h>
#import <Photon/PXViewController.h>
#import <Photon/PXTabBar.h>


@class PXTabBar;
@protocol PXTabBarControllerDelegate, PXTabBarDelegate;


@interface PXTabBarController : PXViewController <PXTabBarDelegate>

@property (assign) IBOutlet PXTabBar *tabBar;
@property (assign) IBOutlet NSView *containerView;

@property (unsafe_unretained) id <PXTabBarControllerDelegate> delegate;

@property (assign) NSArray *viewControllers;

@property (strong, readonly) PXViewController *selectedViewController;
@property (assign, readonly) NSUInteger selectedIndex;

- (void)addViewController:(PXViewController *)viewController;
- (void)insertViewController:(PXViewController *)viewController atIndex:(NSUInteger)index;
- (void)removeViewController:(PXViewController *)viewController;
- (void)removeViewControllerAtIndex:(NSUInteger)index;
- (PXViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(PXViewController *)viewController;

- (void)selectViewController:(PXViewController *)viewController;
- (void)selectViewControllerAtIndex:(NSUInteger)index;

@end


@protocol PXTabBarControllerDelegate <NSObject>

@optional

- (void)tabBarController:(PXTabBarController *)aTabBarController willAddViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController didAddViewController:(PXViewController *)viewController;

- (void)tabBarController:(PXTabBarController *)aTabBarController willRemoveViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController didRemoveViewController:(PXViewController *)viewController;

- (BOOL)tabBarController:(PXTabBarController *)aTabBarController shouldSelectViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController willSelectViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController didSelectViewController:(PXViewController *)viewController;

@end


// Notifications
PHOTON_EXTERN NSString * const PXTabBarControllerWillAddViewControllerNotification;
PHOTON_EXTERN NSString * const PXTabBarControllerDidAddViewControllerNotification;

PHOTON_EXTERN NSString * const PXTabBarControllerWillRemoveViewControllerNotification;
PHOTON_EXTERN NSString * const PXTabBarControllerDidRemoveViewControllerNotification;

PHOTON_EXTERN NSString * const PXTabBarControllerWillSelectViewControllerNotification;
PHOTON_EXTERN NSString * const PXTabBarControllerDidSelectViewControllerNotification;

