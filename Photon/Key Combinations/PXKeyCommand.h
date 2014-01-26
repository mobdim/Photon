//
//  PXKeyCommand.h
//  Photon
//
//  Created by Logan Collins on 1/25/14.
//  Copyright (c) 2014 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef NS_OPTIONS(NSUInteger, PXKeyModifierFlags) {
    PXKeyModifierAlphaShift     = 1 << 16,
    PXKeyModifierShift          = 1 << 17,
    PXKeyModifierControl        = 1 << 18,
    PXKeyModifierAlternate      = 1 << 19,
    PXKeyModifierCommand        = 1 << 20,
};


@class PXKeyCombination;


@interface PXKeyCommand : NSObject <NSSecureCoding, NSCopying>

- (id)initWithKeyCode:(CGKeyCode)keyCode modifierFlags:(PXKeyModifierFlags)modifierFlags;

@property (readonly) CGKeyCode keyCode;
@property (readonly) PXKeyModifierFlags modifierFlags;

- (NSArray *)allTargets;
- (NSArray *)actionsForTarget:(id)target;
- (void)addTarget:(id)target action:(SEL)action;
- (void)removeTarget:(id)target action:(SEL)action;

- (void)sendActions;
- (void)sendAction:(SEL)action to:(id)target;

// Registration
+ (NSArray *)registeredKeyCommands;
+ (void)registerKeyCommand:(PXKeyCommand *)keyCommand;
+ (void)unregisterKeyCommand:(PXKeyCommand *)keyCommand;

@end
