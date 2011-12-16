//
//  PXNavigationPathComponentCell.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXNavigationPathComponentCell : NSPathComponentCell

@property (assign, getter=isFirstItem) BOOL firstItem;
@property (assign, getter=isLastItem) BOOL lastItem;

@end
