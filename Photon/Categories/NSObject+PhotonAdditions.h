//
//  NSObject+PhotonAdditions.h
//  Photon
//
//  Created by Logan Collins on 2/22/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (PhotonAdditions)

+ (void)px_exchangeInstanceMethodForSelector:(SEL)selector1 withSelector:(SEL)selector2;

@end
