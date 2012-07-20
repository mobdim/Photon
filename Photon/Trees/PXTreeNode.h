//
//  PXTreeNode.h
//  Photon
//
//  Created by Logan Collins on 7/8/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 * @protocol PXTreeNode
 * @abstract Implemented by objects participating in a tree of objects
 */
@protocol PXTreeNode <NSObject>

@required

@property (copy, readonly) NSString *title;                 /* The title of the item */
@property (copy, readonly) NSImage *image;                  /* The image of the item */
@property (readonly) NSUInteger order;                      /* The order of the item, 0 is lowest */
@property (copy, readonly) NSSet *children;                 /* The set of child items */

@property (readonly, getter=isSelectable) BOOL selectable;	/* If the item is selectable by the user */
@property (readonly, getter=isEditable) BOOL editable;		/* If the item is editable by the user */
@property (readonly, getter=isGroupItem) BOOL groupItem;	/* If the item is a group heading */

@optional

@property (copy, readonly) NSString *persistenceString;     /* A unique string representation of the receiver, or nil */

@end


/*!
 * @class PXTreeNode
 * @abtract A concrete, generic implementation of the PXTreeNode protocol
 */
@interface PXTreeNode : NSObject <PXTreeNode>

@property (copy) NSString *title;
@property (copy) NSImage *image;
@property NSUInteger order;

@property (copy) NSSet *children;
- (void)addChild:(id <PXTreeNode>)child;
- (void)removeChild:(id <PXTreeNode>)child;

@property (getter=isSelectable) BOOL selectable;
@property (getter=isEditable) BOOL editable;
@property (getter=isGroupItem) BOOL groupItem;

@end
