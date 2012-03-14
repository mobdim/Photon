//
//  PXTabBarController_Private.h
//  Photon
//
//  Created by Logan Collins on 3/13/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Photon/PXTabBarController.h>


@interface PXTabBarController ()

- (void)addViewController:(PXViewController *)viewController;
- (void)insertViewController:(PXViewController *)viewController atIndex:(NSUInteger)index;
- (void)removeViewController:(PXViewController *)viewController;
- (void)removeViewControllerAtIndex:(NSUInteger)index;
- (PXViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(PXViewController *)viewController;

- (void)selectViewController:(PXViewController *)viewController;
- (void)selectViewControllerAtIndex:(NSUInteger)index;

@end
