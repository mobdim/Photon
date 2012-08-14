//
//  PXNavigationItem.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXNavigationItem : NSObject

@property (copy) NSString *title;
@property (copy) NSImage *image;
@property (strong) NSMenu *menu;
@property (strong) NSView *accessoryView;
@property (unsafe_unretained) id representedObject;

@end
