//
//  NSObject+PXKeyValueBinding.h
//  Photon
//
//  Created by Logan Collins on 8/10/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (PXKeyValueBinding)

- (id)valueForBinding:(NSString *)binding;
- (void)setValue:(id)value forBinding:(NSString *)binding;
- (id)controllerForBinding:(NSString *)binding;
- (NSString *)keyPathForBinding:(NSString *)binding;
- (NSValueTransformer *)valueTransformerForBinding:(NSString *)binding;

@end
