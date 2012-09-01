//
//  NSObject+PhotonAdditions.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "NSObject+PhotonAdditions.h"


@implementation NSObject (PhotonAdditions)

- (void)px_addObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths options:(NSKeyValueObservingOptions)options context:(void *)context {
    for (NSString *keyPath in keyPaths) {
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

- (void)px_removeObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths {
    for (NSString *keyPath in keyPaths) {
        [self removeObserver:observer forKeyPath:keyPath];
    }
}

- (void)px_removeObserver:(NSObject *)observer forKeyPaths:(NSSet *)keyPaths context:(void *)context {
    for (NSString *keyPath in keyPaths) {
        [self removeObserver:observer forKeyPath:keyPath context:context];
    }
}

@end
