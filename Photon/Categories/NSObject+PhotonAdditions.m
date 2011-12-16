//
//  NSObject+PhotonAdditions.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "NSObject+PhotonAdditions.h"


@implementation NSObject (PhotonAdditions)

- (void)addObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths options:(NSKeyValueObservingOptions)options context:(void *)context {
    for (NSString *keyPath in keyPaths) {
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths {
    for (NSString *keyPath in keyPaths) {
        [self removeObserver:observer forKeyPath:keyPath];
    }
}

@end
