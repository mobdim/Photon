//
//  PXTableViewCell.h
//  Photon
//
//  Created by Logan Collins on 3/1/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


enum {
    PXTableViewCellBadgeStyleCapsule = 0,
    PXTableViewCellBadgeStyleBox,
};
typedef NSUInteger PXTableViewCellBadgeStyle;


@interface PXTableViewCell : NSTextFieldCell

@property (copy) NSImage *icon;
@property (copy) NSImage *selectedIcon;
@property (assign) NSSize iconSize;
@property (assign) CGFloat iconAlpha;

@property (copy) NSString *subtitle;
@property (copy) NSFont *subtitleFont;
@property (copy) NSColor *subtitleColor;

@property (copy) NSString *badgeString;
@property (copy) NSColor *badgeColor;
@property (assign) PXTableViewCellBadgeStyle badgeStyle;
@property (strong) NSMenu *badgeMenu;

@end
