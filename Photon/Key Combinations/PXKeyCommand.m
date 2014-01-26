//
//  PXKeyCommand.m
//  Photon
//
//  Created by Logan Collins on 1/25/14.
//  Copyright (c) 2014 Sunflower Softworks. All rights reserved.
//

#import "PXKeyCommand.h"

#import <Carbon/Carbon.h>
#import <objc/runtime.h>


@interface PXKeyCommand ()

@property (readwrite) CGKeyCode keyCode;
@property (readwrite) PXKeyModifierFlags modifierFlags;

@end


@implementation PXKeyCommand {
    NSMutableArray *_responderChainActions;
    NSMapTable *_targetsToActions;
}

static BOOL __eventHandlerInstalled = NO;
static NSMutableDictionary *__keyCommandsByID = nil;

+ (void)initialize {
    if (self == [PXKeyCommand class]) {
        __keyCommandsByID = [[NSMutableDictionary alloc] init];
    }
}


#pragma mark -
#pragma mark Registration

static NSString * const PXKeyCommandCarbonHotKeyAssociationKey = @"PXKeyCommandCarbonHotKeyAssociationKey";
static NSString * const PXKeyCommandIDAssociationKey = @"PXKeyCommandIDAssociationKey";

+ (NSArray *)registeredKeyCommands {
    return [__keyCommandsByID allValues];
}

+ (void)registerKeyCommand:(PXKeyCommand *)keyCommand {
    NSParameterAssert(keyCommand != nil);
    
    NSValue *pointerValue = objc_getAssociatedObject(keyCommand, (__bridge void *)PXKeyCommandCarbonHotKeyAssociationKey);
    if (pointerValue != nil) {
        return;
    }
    
    static UInt32 __nextEventHotKeyID = 1;
    
	OSStatus err;
	EventHotKeyID hotKeyID;
	EventHotKeyRef carbonHotKey;
    
	hotKeyID.signature = 'HCHk';
	hotKeyID.id = __nextEventHotKeyID;
    
    UInt32 modifiers = 0;
    if (keyCommand.modifierFlags & PXKeyModifierAlphaShift) {
        modifiers |= alphaLock;
    }
    if (keyCommand.modifierFlags & PXKeyModifierCommand) {
        modifiers |= cmdKey;
    }
    if (keyCommand.modifierFlags & PXKeyModifierAlternate) {
        modifiers |= optionKey;
    }
    if (keyCommand.modifierFlags & PXKeyModifierControl) {
        modifiers |= controlKey;
    }
    if (keyCommand.modifierFlags & PXKeyModifierShift) {
        modifiers |= shiftKey;
    }
	
	err = RegisterEventHotKey(keyCommand.keyCode,
							  modifiers,
							  hotKeyID,
							  GetEventDispatcherTarget(),
							  kEventHotKeyNoOptions,
							  &carbonHotKey);
    if (err != noErr) {
        NSLog(@"Error registering key command: %@", keyCommand);
    }
    
    pointerValue = [NSValue valueWithPointer:carbonHotKey];
    
    [__keyCommandsByID setObject:keyCommand forKey:[NSNumber numberWithInteger:hotKeyID.id]];
    
    objc_setAssociatedObject(keyCommand, (__bridge void *)PXKeyCommandCarbonHotKeyAssociationKey, pointerValue, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(keyCommand, (__bridge void *)PXKeyCommandIDAssociationKey, [NSNumber numberWithInteger:hotKeyID.id], OBJC_ASSOCIATION_RETAIN);
    
    __nextEventHotKeyID++;
    
    
    // Install event handler
    if (!__eventHandlerInstalled) {
		EventTypeSpec eventSpec[2] = {
			{ kEventClassKeyboard, kEventHotKeyPressed },
			{ kEventClassKeyboard, kEventHotKeyReleased }
		};
		
		err = InstallEventHandler(GetEventDispatcherTarget(), (EventHandlerProcPtr)PXKeyCommandHotKeyEventHandler, 2, eventSpec, NULL, NULL);
        if (err != noErr) {
            NSLog(@"Error registering global key command event handler: %@", keyCommand);
        }
        
        __eventHandlerInstalled = YES;
    }
}

+ (void)unregisterKeyCommand:(PXKeyCommand *)keyCommand {
    NSParameterAssert(keyCommand != nil);
    
    OSStatus err;
    
    NSValue *pointerValue = objc_getAssociatedObject(keyCommand, (__bridge void *)PXKeyCommandCarbonHotKeyAssociationKey);
    if (pointerValue != nil) {
        EventHotKeyRef carbonHotKey = [pointerValue pointerValue];
        err = UnregisterEventHotKey(carbonHotKey);
        if (err != noErr) {
            NSLog(@"Error unregistering key command: %@", keyCommand);
        }
        
        objc_setAssociatedObject(keyCommand, (__bridge void *)PXKeyCommandCarbonHotKeyAssociationKey, nil, OBJC_ASSOCIATION_RETAIN);
        objc_setAssociatedObject(keyCommand, (__bridge void *)PXKeyCommandIDAssociationKey, nil, OBJC_ASSOCIATION_RETAIN);
    }
}

+ (OSStatus)handleCarbonEventRef:(EventRef)inEvent {
    OSStatus err;
	EventHotKeyID hotKeyID;
	PXKeyCommand *keyCommand;
    
	NSAssert(GetEventClass(inEvent) == kEventClassKeyboard, @"Unknown event class");
    
	err = GetEventParameter(inEvent,
							kEventParamDirectObject,
							typeEventHotKeyID,
							nil,
							sizeof(EventHotKeyID),
							nil,
							&hotKeyID);
	if (err != noErr) {
		return err;
    }
	
	NSAssert(hotKeyID.signature == 'HCHk', @"Invalid hot key");
	
	keyCommand = [__keyCommandsByID objectForKey:[NSNumber numberWithInteger:hotKeyID.id]];
	
    UInt32 kind = GetEventKind(inEvent);
	switch (kind) {
		case kEventHotKeyPressed:
            [keyCommand sendActions];
            break;
		case kEventHotKeyReleased:
            // no-op
            break;
		default:
            NSAssert(0, @"Unknown event kind");
	}
	
	return noErr;
}

static OSStatus PXKeyCommandHotKeyEventHandler(EventHandlerCallRef inHandlerRef, EventRef inEvent, void *refCon) {
	return [PXKeyCommand handleCarbonEventRef:inEvent];
}


#pragma mark -
#pragma mark Key Commands

- (id)init {
	@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"PXKeyCommand must be initialized with a key code and modifiers" userInfo:nil];
}

- (id)initWithKeyCode:(CGKeyCode)keyCode modifierFlags:(PXKeyModifierFlags)modifierFlags; {
	self = [super init];
	if (self) {
		self.keyCode = keyCode;
		self.modifierFlags = modifierFlags;
        
        _responderChainActions = [NSMutableArray array];
        _targetsToActions = [NSMapTable weakToStrongObjectsMapTable];
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
	PXKeyCommand *key = [[[self class] allocWithZone:zone] initWithKeyCode:self.keyCode modifierFlags:self.modifierFlags];
	return key;
}

- (NSArray *)allTargets {
    return [[_targetsToActions keyEnumerator] allObjects];
}

- (NSArray *)actionsForTarget:(id)target {
    return [_targetsToActions objectForKey:target];
}

- (void)addTarget:(id)target action:(SEL)action {
    if (target != nil) {
        NSMutableArray *array = [_targetsToActions objectForKey:target];
        if (array == nil) {
            array = [NSMutableArray array];
            [_targetsToActions setObject:array forKey:target];
        }
        [array addObject:NSStringFromSelector(action)];
    }
    else {
        [_responderChainActions addObject:NSStringFromSelector(action)];
    }
}

- (void)removeTarget:(id)target action:(SEL)action {
    if (target != nil) {
        NSMutableArray *array = [_targetsToActions objectForKey:target];
        if (action != NULL) {
            [array removeObject:NSStringFromSelector(action)];
        }
        else {
            [_targetsToActions removeObjectForKey:target];
        }
    }
    else {
        if (action != NULL) {
            [_responderChainActions addObject:NSStringFromSelector(action)];
            for (id aTarget in [self allTargets]) {
                NSMutableArray *array = [_targetsToActions objectForKey:aTarget];
                [array removeObject:NSStringFromSelector(action)];
            }
        }
        else {
            [_responderChainActions removeAllObjects];
            [_targetsToActions removeAllObjects];
        }
    }
}

- (void)sendActions {
    for (id target in _targetsToActions) {
        NSArray *actions = [_targetsToActions objectForKey:target];
        for (NSString *selectorString in actions) {
            SEL action = NSSelectorFromString(selectorString);
            [self sendAction:action to:target];
        }
    }
    
    for (NSString *selectorString in _responderChainActions) {
        SEL action = NSSelectorFromString(selectorString);
        [self sendAction:action to:nil];
    }
}

- (void)sendAction:(SEL)action to:(id)target {
    NSParameterAssert(action != NULL);
    [[NSApplication sharedApplication] sendAction:action to:target from:self];
}

@end
