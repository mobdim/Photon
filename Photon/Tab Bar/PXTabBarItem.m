//
//  PXTabBarItem.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXTabBarItem.h"


@implementation PXTabBarItem

@synthesize title;
@synthesize image;
@synthesize representedObject;
@synthesize badgeValue;
@synthesize tag;
@synthesize toolTip;

#pragma mark -
#pragma mark Tool Tips

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData {
    return [self toolTip];
}

@end
