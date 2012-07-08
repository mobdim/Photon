//
//  PXTreeNode.m
//  Photon
//
//  Created by Logan Collins on 7/8/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXTreeNode.h"


@implementation PXTreeNode {
    NSMutableSet *_children;
}

@synthesize title=_title;
@synthesize image=_image;
@synthesize order=_order;

@synthesize selectable=_selectable;
@synthesize editable=_editable;
@synthesize groupItem=_groupItem;

- (id)init {
    self = [super init];
    if (self) {
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
    if (![children isEqualToSet:newChildren]) {
		NSSet *objects = [NSSet setWithSet:children];
		[self willChangeValueForKey:@"children" withSetMutation:NSKeyValueSetSetMutation usingObjects:objects];
		[children setSet:children];
		[self didChangeValueForKey:@"children" withSetMutation:NSKeyValueSetSetMutation usingObjects:objects];
	}
}

- (void)addChild:(id <LCSourceListItem>)child {
    if (![children containsObject:child]) {
		NSSet *objects = [NSSet setWithObject:child];
		[self willChangeValueForKey:@"children" withSetMutation:NSKeyValueUnionSetMutation usingObjects:objects];
		[children addObject:child];
		[self didChangeValueForKey:@"children" withSetMutation:NSKeyValueUnionSetMutation usingObjects:objects];
	}
}

- (void)removeChild:(id <LCSourceListItem>)child {
    if ([children containsObject:child]) {
		NSSet *objects = [NSSet setWithObject:child];
		[self willChangeValueForKey:@"children" withSetMutation:NSKeyValueMinusSetMutation usingObjects:objects];
		[children removeObject:child];
		[self didChangeValueForKey:@"children" withSetMutation:NSKeyValueMinusSetMutation usingObjects:objects];
	}
}

@end
