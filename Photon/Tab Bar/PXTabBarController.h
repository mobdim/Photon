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

@property (strong) PXViewController *selectedViewController;
@property (assign) NSUInteger selectedIndex;

@property (assign) BOOL animates;

@end


@protocol PXTabBarControllerDelegate <NSObject>

@optional

- (BOOL)tabBarController:(PXTabBarController *)aTabBarController shouldSelectViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController willSelectViewController:(PXViewController *)viewController;
- (void)tabBarController:(PXTabBarController *)aTabBarController didSelectViewController:(PXViewController *)viewController;

@end
