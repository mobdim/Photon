//
//  PXKeyCombinationField.h
//  LCToolkit
//
//  Created by Logan Collins on 7/19/09.
//  Copyright 2009 Logan Collins. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PXKeyCombination.h>


@protocol PXKeyCombinationFieldDelegate;


@interface PXKeyCombinationField : NSControl

@property (weak) IBOutlet id <PXKeyCombinationFieldDelegate> delegate;

@property (copy) PXKeyCombination *keyCombination;

@property PXKeyModifierFlags allowedModifierFlags;	/* Set the allowed modifiers */
@property PXKeyModifierFlags requiredModifierFlags;	/* Set the required modifiers */

@property BOOL allowsKeyOnly;			/* Allow the field to capture keys without modifiers */
@property BOOL allowsEscapeKeys;		/* Allow the field to capture Escape and Delete keys */
@property BOOL allowsGlobalHotKeys;		/* Allow the field to capture global hot keys */

@end


@protocol PXKeyCombinationFieldDelegate <NSObject>

@optional

- (void)keyCombinationFieldDidChange:(PXKeyCombinationField *)field;

@end
