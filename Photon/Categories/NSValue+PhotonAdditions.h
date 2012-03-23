//
//  NSValue+PhotonAdditions.h
//  Photon
//
//  Created by Logan Collins on 3/23/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photon/PXGeometry.h>


@interface NSValue (PhotonAdditions)

+ (NSValue *)valueWithPXEdgeInsets:(PXEdgeInsets)edgeInsets;

- (PXEdgeInsets)PXEdgeInsetsValue;

@end
