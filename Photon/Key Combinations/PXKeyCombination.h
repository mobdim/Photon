//
//  PXKeyCombination.h
//  Photon
//
//  Created by Logan Collins on 1/25/14.
//  Copyright (c) 2014 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PXKeyCommand.h>


@interface PXKeyCombination : NSObject <NSSecureCoding, NSCopying>

- (id)initWithKeyCode:(CGKeyCode)keyCode modifierFlags:(PXKeyModifierFlags)modifierFlags;

@property (readonly) CGKeyCode keyCode;
@property (readonly) PXKeyModifierFlags modifierFlags;

- (BOOL)isEqualToKeyCombination:(PXKeyCombination *)combination;

+ (NSString *)stringForKeyCode:(CGKeyCode)keyCode;
+ (NSString *)stringForKeyModifierFlags:(PXKeyModifierFlags)flags;
+ (NSString *)stringForKeyCode:(CGKeyCode)keyCode modifierFlags:(PXKeyModifierFlags)flags;

+ (NSString *)localizedStringForKeyModifierFlags:(PXKeyModifierFlags)flags;
+ (NSString *)localizedStringForKeyCode:(CGKeyCode)keyCode modifierFlags:(PXKeyModifierFlags)flags;

@end


@interface PXKeyCombinationValidator : NSObject

- (BOOL)isKeyCombinationTaken:(PXKeyCombination *)keyCombination error:(NSError **)error;

@end
