//
//  PXAccessibility.m
//  Photon
//
//  Created by Logan Collins on 2/27/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "PXAccessibility.h"


@implementation NSObject (PXAccessibility)

- (id)px_accessibilityOverrideTargetForAttribute:(NSString *)attribute {
    id accessibilityTarget = self;
    if ([accessibilityTarget isKindOfClass:[NSControl class]] && [accessibilityTarget cell] != nil) {
        accessibilityTarget = [accessibilityTarget cell];
    }
    return accessibilityTarget;
}

@end
