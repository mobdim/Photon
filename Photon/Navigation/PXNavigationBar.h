//
//  PXNavigationBar.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PhotonDefines.h>
#import <Photon/PXAppearance.h>


typedef PHOTON_ENUM(NSUInteger, PXNavigationBarStyle) {
    PXNavigationBarStyleLight = 0,
    PXNavigationBarStyleDark,
};


@class PXNavigationItem;
@protocol PXNavigationBarDelegate;


@interface PXNavigationBar : NSView <PXAppearance>

@property (nonatomic, weak) id <PXNavigationBarDelegate> delegate;

@property (nonatomic) PXNavigationBarStyle style;

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, strong, readonly) PXNavigationItem *topItem;
@property (nonatomic, strong, readonly) PXNavigationItem *backItem;

- (void)pushNavigationItem:(PXNavigationItem *)item;
- (void)popToNavigationItem:(PXNavigationItem *)item;
- (void)popToRootNavigationItem;
- (void)popNavigationItem;

@end


@protocol PXNavigationBarDelegate <NSObject>

@optional

- (BOOL)navigationBar:(PXNavigationBar *)navigationBar shouldPushItem:(PXNavigationItem *)item;
- (void)navigationBar:(PXNavigationBar *)navigationBar didPushItem:(PXNavigationItem *)item;
- (BOOL)navigationBar:(PXNavigationBar *)navigationBar shouldPopToItem:(PXNavigationItem *)item;
- (void)navigationBar:(PXNavigationBar *)navigationBar didPopToItem:(PXNavigationItem *)item;

@end
