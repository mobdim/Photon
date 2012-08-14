//
//  PXNavigationPathCell.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationPathCell.h"
#import "PXNavigationPathComponentCell.h"


@implementation PXNavigationPathCell

+ (Class)pathComponentCellClass {
    return [PXNavigationPathComponentCell class];
}

@end
