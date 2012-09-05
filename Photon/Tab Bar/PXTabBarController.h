//
//  PXTabBarController.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PhotonDefines.h>
#import <Photon/PXViewController.h>
#import <Photon/PXTabBar.h>


@class PXTabBar;
@protocol PXTabBarControllerDelegate, PXTabBarDelegate;


/*!
 * @class PXTabBarController
 * @abstract Coordinates a tabbed set of view controllers
 */
@interface PXTabBarController : PXViewController <PXTabBarDelegate>

@property IBOutlet PXTabBar *tabBar;
@property IBOutlet NSView *containerView;

@property (nonatomic, weak) id <PXTabBarControllerDelegate> delegate;

@property (nonatomic) NSArray *viewControllers;

@property (nonatomic, strong) PXViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic) BOOL animates;

@end


@protocol PXTabBarControllerDelegate <NSObject>

@optional

- (BOOL)tabBarController:(PXTabBarController *)aTabBarController shouldSelectViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController willSelectViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController didSelectViewController:(PXViewController *)viewController;

@end
