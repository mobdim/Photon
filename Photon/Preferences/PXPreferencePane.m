//
//  PXPreferencePane.m
//  Photon
//
//  Created by Logan Collins on 11/28/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXPreferencePane.h"


@implementation PXPreferencePane

@dynamic title;
@synthesize identifier=_identifier;
@synthesize image=_image;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

@end
