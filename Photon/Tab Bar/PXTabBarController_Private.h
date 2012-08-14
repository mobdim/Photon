//
//  PXTabBarController_Private.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Photon/PXTabBarController.h>


@interface PXTabBarController () <NSAnimationDelegate>

- (void)addViewController:(PXViewController *)viewController;
- (void)insertViewController:(PXViewController *)viewController atIndex:(NSUInteger)index;
- (void)removeViewController:(PXViewController *)viewController;
- (void)removeViewControllerAtIndex:(NSUInteger)index;
- (PXViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(PXViewController *)viewController;

- (void)selectViewController:(PXViewController *)viewController;
- (void)selectViewControllerAtIndex:(NSUInteger)index;

- (void)replaceView:(NSView *)oldView withView:(NSView *)newView push:(BOOL)shouldPush animated:(BOOL)isAnimated;

@end
