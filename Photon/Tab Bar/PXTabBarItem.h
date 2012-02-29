//
//  PXTabBarItem.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXTabBarItem : NSObject

@property (copy) NSString *title;
@property (copy) NSImage *image;
@property (unsafe_unretained) id representedObject;
@property (copy) NSString *badgeValue;

@end
