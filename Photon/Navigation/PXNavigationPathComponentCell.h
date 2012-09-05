//
//  PXNavigationPathComponentCell.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXNavigationPathComponentCell : NSPathComponentCell

@property (nonatomic, getter=isFirstItem) BOOL firstItem;
@property (nonatomic, getter=isLastItem) BOOL lastItem;

@end
