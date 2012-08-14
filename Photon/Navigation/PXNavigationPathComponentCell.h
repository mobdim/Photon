//
//  PXNavigationPathComponentCell.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXNavigationPathComponentCell : NSPathComponentCell

@property (getter=isFirstItem) BOOL firstItem;
@property (getter=isLastItem) BOOL lastItem;

@end
