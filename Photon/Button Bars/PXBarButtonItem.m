//
//  PXBarButtonItem.m
//  Photon
//
//  Created by Logan Collins on 9/7/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXBarButtonItem.h"


@implementation PXBarButtonItem

- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    self = [self init];
    if (self) {
        self.title = title;
        self.target = target;
        self.action = action;
    }
    return self;
}

- (id)initWithImage:(NSImage *)image target:(id)target action:(SEL)action {
    self = [self init];
    if (self) {
        self.image = image;
        self.target = target;
        self.action = action;
    }
    return self;
}

@end
