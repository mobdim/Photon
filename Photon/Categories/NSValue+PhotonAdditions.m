//
//  NSValue+PhotonAdditions.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "NSValue+PhotonAdditions.h"


@implementation NSValue (PhotonAdditions)

+ (NSValue *)valueWithPXEdgeInsets:(PXEdgeInsets)edgeInsets {
    return [self valueWithBytes:&edgeInsets objCType:@encode(PXEdgeInsets)];
}

- (PXEdgeInsets)PXEdgeInsetsValue {
    PXEdgeInsets edgeInsets;
    [self getValue:&edgeInsets];
    return edgeInsets;
}

@end
