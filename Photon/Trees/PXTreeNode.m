//
//  PXTreeNode.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXTreeNode.h"


@implementation PXTreeNode {
    NSMutableSet *_children;
}

- (id)init {
    self = [super init];
    if (self) {
        self.selectable = YES;
        self.editable = NO;
        self.groupItem = NO;
        
        _children = [NSMutableSet set];
    }
    return self;
}


#pragma mark -
#pragma mark Accessors

- (NSArray *)children {
    return [_children copy];
}

- (void)setChildren:(NSSet *)children {
    if (![_children isEqualToSet:children]) {
        NSSet *objects = [NSSet setWithSet:children];
        [self willChangeValueForKey:@"children" withSetMutation:NSKeyValueSetSetMutation usingObjects:objects];
        [_children setSet:children];
        [self didChangeValueForKey:@"children" withSetMutation:NSKeyValueSetSetMutation usingObjects:objects];
    }
}

- (void)addChild:(id <PXTreeNode>)child {
    if (![_children containsObject:child]) {
        NSSet *objects = [NSSet setWithObject:child];
        [self willChangeValueForKey:@"children" withSetMutation:NSKeyValueUnionSetMutation usingObjects:objects];
        [_children addObject:child];
        [self didChangeValueForKey:@"children" withSetMutation:NSKeyValueUnionSetMutation usingObjects:objects];
    }
}

- (void)removeChild:(id <PXTreeNode>)child {
    if ([_children containsObject:child]) {
        NSSet *objects = [NSSet setWithObject:child];
        [self willChangeValueForKey:@"children" withSetMutation:NSKeyValueMinusSetMutation usingObjects:objects];
        [_children removeObject:child];
        [self didChangeValueForKey:@"children" withSetMutation:NSKeyValueMinusSetMutation usingObjects:objects];
    }
}

@end
