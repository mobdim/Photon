//
//  PXNavigationBar.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PXGradientView.h>


@class PXNavigationItem;
@protocol PXNavigationBarDelegate;


@interface PXNavigationBar : PXGradientView

@property (weak) id <PXNavigationBarDelegate> delegate;
@property (copy) NSArray *items;
@property (strong, readonly) PXNavigationItem *topItem;

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
