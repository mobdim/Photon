//
//  PXNavigationItem.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXNavigationItem : NSObject

@property (copy) NSString *title;
@property (copy) NSImage *image;
@property (retain) NSMenu *menu;
@property (retain) NSView *accessoryView;
@property (weak) id representedObject;

@end
