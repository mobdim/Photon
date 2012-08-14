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


@interface PXTabBarController : PXViewController <PXTabBarDelegate>

@property IBOutlet PXTabBar *tabBar;
@property IBOutlet NSView *containerView;

@property (weak) id <PXTabBarControllerDelegate> delegate;

@property NSArray *viewControllers;

@property (strong) PXViewController *selectedViewController;
@property NSUInteger selectedIndex;

@property BOOL animates;

@end


@protocol PXTabBarControllerDelegate <NSObject>

@optional

- (BOOL)tabBarController:(PXTabBarController *)aTabBarController shouldSelectViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController willSelectViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController didSelectViewController:(PXViewController *)viewController;

@end
