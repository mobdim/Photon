//
//  PXTableViewCell.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PhotonDefines.h>


typedef PHOTON_ENUM(NSUInteger, PXTableViewCellBadgeStyle) {
    PXTableViewCellBadgeStyleCapsule = 0,
    PXTableViewCellBadgeStyleBox,
};


@interface PXTableViewCell : NSTextFieldCell

@property (copy) NSImage *icon;
@property (copy) NSImage *selectedIcon;
@property NSSize iconSize;
@property CGFloat iconAlpha;

@property (copy) NSString *subtitle;
@property (copy) NSFont *subtitleFont;
@property (copy) NSColor *subtitleColor;

@property (copy) NSString *badgeString;
@property (copy) NSColor *badgeColor;
@property PXTableViewCellBadgeStyle badgeStyle;
@property (strong) NSMenu *badgeMenu;

@end
