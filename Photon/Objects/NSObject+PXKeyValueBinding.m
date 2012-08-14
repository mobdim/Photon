//
//  NSObject+PXKeyValueBinding.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "NSObject+PXKeyValueBinding.h"


@implementation NSObject (PXKeyValueBinding)

- (id)valueForBinding:(NSString *)binding {
    id controller = [self controllerForBinding:binding];
    id value = [controller valueForKeyPath:[self keyPathForBinding:binding]];
    
    NSValueTransformer *transformer = [self valueTransformerForBinding:binding];
    if (transformer != nil) {
        value = [transformer transformedValue:value];
    }
    
    return value;
}

- (void)setValue:(id)value forBinding:(NSString *)binding {
    NSValueTransformer *transformer = [self valueTransformerForBinding:binding];
    if (transformer != nil && [[transformer class] allowsReverseTransformation]) {
        value = [transformer reverseTransformedValue:value];
    }
    
    id controller = [self controllerForBinding:binding];
    
    if (controller != nil) {
        [controller setValue:value forKeyPath:[self keyPathForBinding:binding]];
    }
}

- (id)controllerForBinding:(NSString *)binding {
    return [[self infoForBinding:binding] objectForKey:NSObservedObjectKey];
}

- (NSString *)keyPathForBinding:(NSString *)binding {
    return [[self infoForBinding:binding] objectForKey:NSObservedKeyPathKey];
}

- (NSValueTransformer *)valueTransformerForBinding:(NSString *)binding {
    NSDictionary *bindingOptions = [[self infoForBinding:binding] objectForKey:NSOptionsKey];
    NSValueTransformer *valueTransformer = [bindingOptions objectForKey:NSValueTransformerBindingOption];
    return (valueTransformer != nil ? valueTransformer : [NSValueTransformer valueTransformerForName:[bindingOptions objectForKey:NSValueTransformerNameBindingOption]]);
}

@end
