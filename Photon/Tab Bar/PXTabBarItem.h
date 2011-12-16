//
//  PXTabBarItem.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXTabBarItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSImage *image;
@property (nonatomic, assign) id representedObject;
@property (nonatomic, copy) NSString *badgeValue;

@end
