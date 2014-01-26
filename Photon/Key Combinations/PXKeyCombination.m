//
//  PXKeyCombination.m
//  Photon
//
//  Created by Logan Collins on 1/25/14.
//  Copyright (c) 2014 Sunflower Softworks. All rights reserved.
//

#import "PXKeyCombination.h"

#import <Carbon/Carbon.h>


typedef NS_ENUM(unichar, KeyboardGlyph) {
	PXKeyGlyphTabRight       = 0x21E5,
	PXKeyGlyphTabLeft        = 0x21E4,
	PXKeyGlyphCommand        = 0x2318,
	PXKeyGlyphOption         = 0x2325,
	PXKeyGlyphShift          = 0x21E7,
	PXKeyGlyphControl        = 0x2303,
	PXKeyGlyphReturn         = 0x2305,
	PXKeyGlyphReturnR2L      = 0x21A9,
	PXKeyGlyphDeleteLeft     = 0x232B,
	PXKeyGlyphDeleteRight    = 0x2326,
	PXKeyGlyphPadClear       = 0x2327,
    PXKeyGlyphLeftArrow      = 0x2190,
	PXKeyGlyphRightArrow     = 0x2192,
	PXKeyGlyphUpArrow        = 0x2191,
	PXKeyGlyphDownArrow      = 0x2193,
    PXKeyGlyphPageDown       = 0x21DF,
	PXKeyGlyphPageUp         = 0x21DE,
	PXKeyGlyphNorthwestArrow = 0x2196,
	PXKeyGlyphSoutheastArrow = 0x2198,
	PXKeyGlyphEscape         = 0x238B,
	PXKeyGlyphHelp           = 0x003F,
};


@interface PXKeyCodeTransformer : NSValueTransformer

@end


@interface PXKeyCombination ()

@property (readwrite) CGKeyCode keyCode;
@property (readwrite) PXKeyModifierFlags modifierFlags;

@end


@implementation PXKeyCombination

- (id)initWithKeyCode:(CGKeyCode)keyCode modifierFlags:(PXKeyModifierFlags)modifierFlags {
	self = [super init];
	if (self) {
		self.keyCode = keyCode;
		self.modifierFlags = modifierFlags;
	}
	return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if (self) {
		self.keyCode = [aDecoder decodeIntegerForKey:@"keyCode"];
		self.modifierFlags = [aDecoder decodeIntegerForKey:@"modifierFlags"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInteger:self.keyCode forKey:@"keyCode"];
	[aCoder encodeInteger:self.modifierFlags forKey:@"modifierFlags"];
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (BOOL)isEqualToKeyCombination:(PXKeyCombination *)combination {
	return ([self keyCode] == [combination keyCode] && [self modifierFlags] == [combination modifierFlags]);
}


#pragma mark -
#pragma mark Strings

+ (NSString *)stringForKeyCode:(CGKeyCode)keyCode; {
    static PXKeyCodeTransformer *keyCodeTransformer = nil;
    if (!keyCodeTransformer) {
        keyCodeTransformer = [[PXKeyCodeTransformer alloc] init];
    }
    return [keyCodeTransformer transformedValue:[NSNumber numberWithShort:keyCode]];
}

+ (NSString *)stringForKeyModifierFlags:(PXKeyModifierFlags)flags {
    NSString *modifierFlagsString = [NSString stringWithFormat:@"%@%@%@%@",
									 (flags & PXKeyModifierControl ? [NSString stringWithFormat:@"%C", PXKeyGlyphControl] : @""),
									 (flags & PXKeyModifierAlternate ? [NSString stringWithFormat:@"%C", PXKeyGlyphOption] : @""),
									 (flags & PXKeyModifierShift ? [NSString stringWithFormat:@"%C", PXKeyGlyphShift] : @""),
									 (flags & PXKeyModifierCommand ? [NSString stringWithFormat:@"%C", PXKeyGlyphCommand] : @"")];
	return modifierFlagsString;
}

+ (NSString *)stringForKeyCode:(CGKeyCode)keyCode modifierFlags:(PXKeyModifierFlags)flags {
    NSString *readableString = [NSString stringWithFormat:@"%@%@",
                                [self stringForKeyModifierFlags:flags],
                                [self stringForKeyCode:keyCode]];
	return readableString;
}

+ (NSString *)localizedStringForKeyModifierFlags:(PXKeyModifierFlags)flags {
    NSString *readableString = [NSString stringWithFormat:@"%@%@%@%@",
								(flags & PXKeyModifierControl ? NSLocalizedStringFromTable(@"Control + ", @"KeyCombinations", nil) : @""),
								(flags & PXKeyModifierAlternate ? NSLocalizedStringFromTable(@"Option + ", @"KeyCombinations", nil) : @""),
								(flags & PXKeyModifierShift ? NSLocalizedStringFromTable(@"Shift + ", @"KeyCombinations", nil) : @""),
								(flags & PXKeyModifierCommand ? NSLocalizedStringFromTable(@"Command + ", @"KeyCombinations", nil) : @"")];
	return readableString;
}

+ (NSString *)localizedStringForKeyCode:(CGKeyCode)keyCode modifierFlags:(PXKeyModifierFlags)flags {
    NSString *readableString = [NSString stringWithFormat:@"%@%@",
                                [self localizedStringForKeyModifierFlags:flags],
                                [self stringForKeyCode:keyCode]];
	return readableString;
}

@end


@implementation PXKeyCodeTransformer

static NSMutableDictionary *__stringToKeyCodeDict = nil;
static NSDictionary *__keyCodeToStringDict = nil;
static NSArray *__padKeysArray = nil;

+ (void)initialize {
    if (self == [PXKeyCodeTransformer class]) {
        __keyCodeToStringDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"F1", @122,
                                 @"F2", @120,
                                 @"F3", @99,
                                 @"F4", @118,
                                 @"F5", @96,
                                 @"F6", @97,
                                 @"F7", @98,
                                 @"F8", @100,
                                 @"F9", @101,
                                 @"F10", @109,
                                 @"F11", @103,
                                 @"F12", @111,
                                 @"F13", @105,
                                 @"F14", @107,
                                 @"F15", @113,
                                 @"F16", @106,
                                 NSLocalizedStringFromTable(@"Space", @"KeyCombinations", nil), @49,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphTabRight], @48,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphDeleteLeft], @51,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphDeleteRight], @117,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphPadClear], @71,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphLeftArrow], @123,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphRightArrow], @124,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphUpArrow], @126,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphDownArrow], @125,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphSoutheastArrow], @119,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphNorthwestArrow], @115,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphEscape], @53,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphPageDown], @121,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphPageUp], @116,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphReturnR2L], @36,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphReturn], @76,
                                 [NSString stringWithFormat:@"%C", PXKeyGlyphHelp], @114,
                                 nil];
        
        __padKeysArray = [[NSArray alloc] initWithObjects:
                          @65, // ,
                          @67, // *
                          @69, // +
                          @75, // /
                          @78, // -
                          @81, // =
                          @82, // 0
                          @83, // 1
                          @84, // 2
                          @85, // 3
                          @86, // 4
                          @87, // 5
                          @88, // 6
                          @89, // 7
                          @91, // 8
                          @92, // 9
                          nil];
        
        __stringToKeyCodeDict = [[NSMutableDictionary alloc] init];
        
        [self regenerateStringToKeyCodeMapping];
    }
}

+ (void)regenerateStringToKeyCodeMapping {
    PXKeyCodeTransformer *transformer = [[self alloc] init];
    [__stringToKeyCodeDict removeAllObjects];
    
    for (unsigned i = 0U; i < 128U; i++) {
        NSNumber *keyCode = [NSNumber numberWithUnsignedInt:i];
        NSString *string = [transformer transformedValue:keyCode];
        if ([string length] > 0) {
            [__stringToKeyCodeDict setObject:keyCode forKey:string];
        }
    }
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass; {
    return [NSString class];
}

- (id)transformedValue:(id)value {
    if (![value isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    CGKeyCode keyCode = [value shortValue];
	
	NSString *unmappedString = [__keyCodeToStringDict objectForKey:[NSNumber numberWithInteger:keyCode]];
	if (unmappedString != nil) {
		return unmappedString;
    }
	
	id transformedValue = nil;
	BOOL isPadKey = [__padKeysArray containsObject:[NSNumber numberWithInteger:keyCode]];
    
    OSStatus err;
	
	TISInputSourceRef currentKeyboardLayout = TISCopyCurrentKeyboardLayoutInputSource();
    if (currentKeyboardLayout == NULL) {
		return nil;
    }
	
	CFDataRef keyboardLayoutData = TISGetInputSourceProperty(currentKeyboardLayout, kTISPropertyUnicodeKeyLayoutData);
	if (keyboardLayoutData != NULL) {
		UCKeyboardLayout *keyboardLayout = (UCKeyboardLayout *)CFDataGetBytePtr(keyboardLayoutData);
		UniCharCount length = 4, realLength;
		UniChar chars[4];
		UInt32 keysDown = 0;
		
		err = UCKeyTranslate(keyboardLayout,
							 keyCode,
							 kUCKeyActionDisplay,
							 0,
							 LMGetKbdType(),
							 kUCKeyTranslateNoDeadKeysBit,
							 &keysDown,
							 length,
							 &realLength,
							 chars);
		if (err != noErr) {
			NSLog(@"Error while transforming key code");
		}
		
		NSString *keyString = [[NSString stringWithCharacters:chars length:1] uppercaseString];
		
		transformedValue = (isPadKey ? [NSString stringWithFormat:NSLocalizedStringFromTable(@"Pad %@", @"KeyCombinations", nil), keyString] : keyString);
	}
	
	CFRelease(currentKeyboardLayout);
    
	return transformedValue;
}

- (id)reverseTransformedValue:(id)value {
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    return [__stringToKeyCodeDict objectForKey:value];
}

@end


@implementation PXKeyCombinationValidator

- (BOOL)isKeyCombinationTaken:(PXKeyCombination *)keyCombination error:(NSError **)error {
	CFArrayRef globalHotKeysRef = NULL;
    OSStatus err = CopySymbolicHotKeys(&globalHotKeysRef);
	if (err != noErr) {
		return YES;
    }
    
    NSArray *globalHotKeys = CFBridgingRelease(globalHotKeysRef);
	
	SInt32 gobalHotKeyFlags;
	signed short globalHotKeyCharCode;
	unichar globalHotKeyUniChar;
	unichar localHotKeyUniChar;
	BOOL globalCommandMod = NO, globalOptionMod = NO, globalShiftMod = NO, globalCtrlMod = NO;
	BOOL localCommandMod = NO, localOptionMod = NO, localShiftMod = NO, localCtrlMod = NO;
	
	PXKeyModifierFlags flags = [keyCombination modifierFlags];
	
    localCommandMod = (flags & PXKeyModifierCommand);
    localOptionMod = (flags & PXKeyModifierAlternate);
    localShiftMod = (flags & PXKeyModifierShift);
    localCtrlMod = (flags & PXKeyModifierControl);
    
	for (NSDictionary *globalHotKeyInfoDictionary in globalHotKeys) {
		if ((__bridge CFBooleanRef)[globalHotKeyInfoDictionary objectForKey:(NSString *)kHISymbolicHotKeyEnabled] != kCFBooleanTrue) {
            continue;
        }
        
        globalHotKeyCharCode = [(NSNumber *)[globalHotKeyInfoDictionary objectForKey:(NSString *)kHISymbolicHotKeyCode] unsignedShortValue];
        globalHotKeyUniChar = [[[NSString stringWithFormat:@"%C", globalHotKeyCharCode] uppercaseString] characterAtIndex:0];
        
        CFNumberGetValue((CFNumberRef)[globalHotKeyInfoDictionary objectForKey:(NSString *)kHISymbolicHotKeyModifiers], kCFNumberSInt32Type, &gobalHotKeyFlags);
        
        globalCommandMod = (gobalHotKeyFlags & NSCommandKeyMask);
        globalOptionMod = (gobalHotKeyFlags & NSAlternateKeyMask);
        globalShiftMod = (gobalHotKeyFlags & NSShiftKeyMask);
        globalCtrlMod = (gobalHotKeyFlags & NSControlKeyMask);
        
        NSString *localKeyString = [PXKeyCombination stringForKeyCode:[keyCombination keyCode]];
        if (![localKeyString length]) {
			return YES;
        }
        
        localHotKeyUniChar = [localKeyString characterAtIndex:0];
        
        if ((globalHotKeyUniChar == localHotKeyUniChar)
            && (globalCommandMod == localCommandMod)
            && (globalOptionMod == localOptionMod)
            && (globalShiftMod == localShiftMod)
            && (globalCtrlMod == localCtrlMod)) {
            if (error != NULL) {
                NSString *description = [NSString stringWithFormat:
                                         NSLocalizedStringFromTable(@"The key combination %@ cannot be used.", @"KeyCombinations", nil),
                                         [PXKeyCombination stringForKeyCode:keyCombination.keyCode modifierFlags:keyCombination.modifierFlags]];
                NSString *recoverySuggestion = [NSString stringWithFormat:
                                                NSLocalizedStringFromTable(@"\"%@\" can't be used because it is already in use by a system-wide keyboard shortcut. If you really want to use this key combination, most shortcuts can be changed in the Keyboard preference pane in System Preferences.", @"KeyCombinations", nil),
                                                [PXKeyCombination localizedStringForKeyCode:keyCombination.keyCode modifierFlags:keyCombination.modifierFlags]];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          description, NSLocalizedDescriptionKey,
                                          recoverySuggestion, NSLocalizedRecoverySuggestionErrorKey,
                                          [NSArray arrayWithObject:@"OK"], NSLocalizedRecoveryOptionsErrorKey,
                                          nil];
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
            }
            return YES;
        }
	}
	
	return [self isKeyCombinationTaken:keyCombination inMenu:[[NSApplication sharedApplication] mainMenu] error:error];
}

- (BOOL)isKeyCombinationTaken:(PXKeyCombination *)keyCombination inMenu:(NSMenu *)menu error:(NSError **)error {
    NSArray *menuItemsArray = [menu itemArray];
	NSUInteger menuItemModifierFlags;
	NSString *menuItemKeyEquivalent;
	
	BOOL menuItemCommandMod = NO, menuItemOptionMod = NO, menuItemShiftMod = NO, menuItemCtrlMod = NO;
	BOOL localCommandMod = NO, localOptionMod = NO, localShiftMod = NO, localCtrlMod = NO;
	
	PXKeyModifierFlags flags = [keyCombination modifierFlags];
	
    localCommandMod = (flags & PXKeyModifierCommand);
    localOptionMod = (flags & PXKeyModifierAlternate);
    localShiftMod = (flags & PXKeyModifierShift);
    localCtrlMod = (flags & PXKeyModifierControl);
	
	for (NSMenuItem *menuItem in menuItemsArray) {
		if ([menuItem hasSubmenu]) {
			if ([self isKeyCombinationTaken:keyCombination inMenu:[menuItem submenu] error:error]) {
				return YES;
			}
		}
		
		if ((menuItemKeyEquivalent = [menuItem keyEquivalent])
            && (![menuItemKeyEquivalent isEqualToString:@""])) {
			menuItemModifierFlags = [menuItem keyEquivalentModifierMask];
            
            menuItemCommandMod = (menuItemModifierFlags & NSCommandKeyMask);
            menuItemOptionMod = (menuItemModifierFlags & NSAlternateKeyMask);
            menuItemShiftMod = (menuItemModifierFlags & NSShiftKeyMask);
            menuItemCtrlMod = (menuItemModifierFlags & NSControlKeyMask);
			
			NSString *localKeyString = [PXKeyCombination stringForKeyCode:[keyCombination keyCode]];
			
			if (([[menuItemKeyEquivalent uppercaseString] isEqualToString:localKeyString])
                && (menuItemCommandMod == localCommandMod)
                && (menuItemOptionMod == localOptionMod)
                && (menuItemShiftMod == localShiftMod)
                && (menuItemCtrlMod == localCtrlMod)) {
                if (error != NULL) {
                    NSString *description = [NSString stringWithFormat:
                                             NSLocalizedStringFromTable(@"The key combination %@ cannot be used.", @"KeyCombinations", nil),
                                             [PXKeyCombination stringForKeyCode:keyCombination.keyCode modifierFlags:keyCombination.modifierFlags]];
                    NSString *recoverySuggestion = [NSString stringWithFormat:
                                                    NSLocalizedStringFromTable(@"\"%@\" cannot be used because it is already in use by the menu item \"%@\".", @"KeyCombinations", nil),
                                                    [PXKeyCombination localizedStringForKeyCode:keyCombination.keyCode modifierFlags:keyCombination.modifierFlags],
                                                    [menuItem title]];
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                              description, NSLocalizedDescriptionKey,
                                              recoverySuggestion, NSLocalizedRecoverySuggestionErrorKey,
                                              [NSArray arrayWithObject:@"OK"], NSLocalizedRecoveryOptionsErrorKey,
                                              nil];
                    *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
                }
				return YES;
			}
		}
	}
	return NO;
}

@end
