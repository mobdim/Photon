//
//  PXTabBar.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PXAppearance.h>


enum {
    PXTabBarStyleLight = 0,
    PXTabBarStyleDark,
};
typedef NSUInteger PXTabBarStyle;


@class PXTabBarItem;
@protocol PXTabBarDelegate;


@interface PXTabBar : NSView <PXAppearance>

@property (unsafe_unretained) id <PXTabBarDelegate> delegate;

@property PXTabBarStyle style;
@property CGFloat cornerRadius;
@property PXAppearanceBorder border;

@property (copy) NSArray *items;
@property (strong) PXTabBarItem *selectedItem;
@property NSUInteger selectedIndex;

@end


@protocol PXTabBarDelegate <NSObject>

@optional

- (BOOL)tabBar:(PXTabBar *)aTabBar shouldSelectItem:(PXTabBarItem *)item;
- (void)tabBar:(PXTabBar *)aTabBar willSelectItem:(PXTabBarItem *)item;
- (void)tabBar:(PXTabBar *)aTabBar didSelectItem:(PXTabBarItem *)item;

@end
