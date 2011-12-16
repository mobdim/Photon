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

@property (weak) id <PXTabBarDelegate> delegate;

@property (copy) NSArray *items;

@property (assign) PXTabBarStyle style;
@property (assign) BOOL showsBottomSeparator;

- (void)addItem:(PXTabBarItem *)item;
- (void)insertItem:(PXTabBarItem *)item atIndex:(NSUInteger)index;
- (void)removeItem:(PXTabBarItem *)item;
- (void)removeItemAtIndex:(NSUInteger)index;
- (void)selectItem:(PXTabBarItem *)item;
- (void)selectItemAtIndex:(NSUInteger)index;
- (PXTabBarItem *)itemAtIndex:(NSUInteger)index;

@property (strong, readonly) PXTabBarItem *selectedItem;

@end


@protocol PXTabBarDelegate <NSObject>

@optional

- (void)tabBar:(PXTabBar *)aTabBar willAddItem:(PXTabBarItem *)item;
- (void)tabBar:(PXTabBar *)aTabBar didAddItem:(PXTabBarItem *)item;

- (void)tabBar:(PXTabBar *)aTabBar willRemoveItem:(PXTabBarItem *)item;
- (void)tabBar:(PXTabBar *)aTabBar didRemoveItem:(PXTabBarItem *)item;

- (BOOL)tabBar:(PXTabBar *)aTabBar shouldSelectItem:(PXTabBarItem *)item;
- (void)tabBar:(PXTabBar *)aTabBar willSelectItem:(PXTabBarItem *)item;
- (void)tabBar:(PXTabBar *)aTabBar didSelectItem:(PXTabBarItem *)item;

- (NSWindow *)tabBar:(PXTabBar *)aTabBar detachableWindowForItem:(PXTabBarItem *)item;

@end
