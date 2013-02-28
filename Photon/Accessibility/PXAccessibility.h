//
//  PXAccessibility.h
//  Photon
//
//  Created by Logan Collins on 2/27/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (PXAccessibility)

- (id)px_accessibilityOverrideTargetForAttribute:(NSString *)attribute;

@end
