//
//  PXNavigationItem.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXNavigationItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSView *titleView;
@property (nonatomic, weak) id representedObject;

@end
