//
//  PXTabBar.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PhotonDefines.h>


typedef NS_ENUM(NSUInteger, PXTabBarStyle) {
    PXTabBarStyleLight = 0,
    PXTabBarStyleDark,
};


typedef NS_OPTIONS(NSUInteger, PXTabBarBorder) {
    PXTabBarBorderNone = 0,
    PXTabBarBorderLeft = (1 << 0),
    PXTabBarBorderTop = (1 << 1),
    PXTabBarBorderRight = (1 << 2),
    PXTabBarBorderBottom = (1 << 3),
};


@class PXTabBarItem;
@protocol PXTabBarDelegate;


@interface PXTabBar : NSView

@property (nonatomic, weak) id <PXTabBarDelegate> delegate;

@property (nonatomic) PXTabBarStyle style;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) PXTabBarBorder border;

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong) PXTabBarItem *selectedItem;
@property (nonatomic) NSUInteger selectedIndex;

@end


@protocol PXTabBarDelegate <NSObject>

@optional

- (void)tabBar:(PXTabBar *)aTabBar didSelectItem:(PXTabBarItem *)item;

@end
