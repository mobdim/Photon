//
//  PXFormatBarItem.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXFormatBarItem.h"
#import "PXFormatBarItem_Private.h"


@implementation PXFormatBarItem

@synthesize identifier;
@synthesize label;
@synthesize image;
@synthesize view;

- (id)initWithIdentifier:(NSString *)anIdentifier {
    self = [super init];
    if (self) {
        self.identifier = anIdentifier;
    }
    return self;
}

@end
