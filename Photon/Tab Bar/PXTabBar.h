//
//  PXTabBar.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PhotonDefines.h>
#import <Photon/PXAppearance.h>


typedef PHOTON_ENUM(NSUInteger, PXTabBarStyle) {
    PXTabBarStyleLight = 0,
    PXTabBarStyleDark,
};


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
