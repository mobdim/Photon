//
//  PXTabBar.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


enum {
	PXTabBarStyleDefault = 0,
	PXTabBarStyleSourceList,
    PXTabBarStylePopover,
    PXTabBarStylePopoverHUD,
};
typedef NSUInteger PXTabBarStyle;


@class PXTabBarItem;
@protocol PXTabBarDelegate;


@interface PXTabBar : NSView

@property (unsafe_unretained) id <PXTabBarDelegate> delegate;

@property (assign) PXTabBarStyle style;

@property (copy) NSArray *items;
@property (strong) PXTabBarItem *selectedItem;
@property (assign) NSUInteger selectedIndex;

@end


@protocol PXTabBarDelegate <NSObject>

@optional

- (BOOL)tabBar:(PXTabBar *)aTabBar shouldSelectItem:(PXTabBarItem *)item;
- (void)tabBar:(PXTabBar *)aTabBar willSelectItem:(PXTabBarItem *)item;
- (void)tabBar:(PXTabBar *)aTabBar didSelectItem:(PXTabBarItem *)item;

@end
