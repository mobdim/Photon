//
//  PXNavigationPathCell.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationPathCell.h"
#import "PXNavigationPathComponentCell.h"


@implementation PXNavigationPathCell

+ (Class)pathComponentCellClass {
    return [PXNavigationPathComponentCell class];
}

@end
