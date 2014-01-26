//
//  PXKeyCombinationFieldCell.h
//  LCToolkit
//
//  Created by Logan Collins on 7/19/09.
//  Copyright 2009 Logan Collins. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <Photon/PXKeyCombination.h>


@protocol PXKeyCombinationFieldCellDelegate;


@interface PXKeyCombinationFieldCell : NSActionCell

@property (weak) IBOutlet id <PXKeyCombinationFieldCellDelegate> delegate;

@property (copy) PXKeyCombination *keyCombination;

@property PXKeyModifierFlags allowedFlagsMask;	/* Set the allowed modifiers mask */
@property PXKeyModifierFlags requiredFlagsMask;	/* Set the required modifiers mask */

@property BOOL allowsKeyOnly;			/* Allow the field to capture keys without modifiers */
@property BOOL allowsEscapeKeys;		/* Allow the field to capture Escape and Delete keys */
@property BOOL allowsGlobalHotKeys;		/* Allow the field to capture global hot keys */

@end


@protocol PXKeyCombinationFieldCellDelegate <NSObject>

@optional

- (void)keyCombinationFieldCellDidChange:(PXKeyCombinationFieldCell *)aCell;

@end
