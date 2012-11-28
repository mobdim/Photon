//
//  PXPreferencePane.h
//  Photon
//
//  Created by Logan Collins on 11/28/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXPreferencePane : NSViewController <NSUserInterfaceItemIdentification>

@property (copy) NSString *identifier;

@property (copy) NSString *title;

@property (copy) NSImage *image;

@end
