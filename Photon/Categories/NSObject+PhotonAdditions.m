//
//  NSObject+PhotonAdditions.m
//  Photon
//
//  Created by Logan Collins on 2/22/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "NSObject+PhotonAdditions.h"

#import <objc/runtime.h>


@implementation NSObject (PhotonAdditions)

+ (void)px_exchangeInstanceMethodForSelector:(SEL)selector1 withSelector:(SEL)selector2 {
    // This method uses class_copyMethodList to determine if the receiver defines a method
    // named selector1 instead of class_getInstanceMethod, because the latter returns superclass
    // methods as well. Swizzling a superclass method is a bad idea.
    
    Method method1 = NULL;
    Method method2 = NULL;
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(self, &methodCount);
    if (methods != NULL) {
        for (NSUInteger i=0; i<methodCount; i++) {
            Method method = methods[i];
            
            if (method_getName(method) == selector1) {
                method1 = method;
            }
            else if (method_getName(method) == selector2) {
                method2 = method;
            }
        }
        free(methods);
    }
    
    if (method1 != nil && method2 != nil) {
        // Class defines selector1
        method_exchangeImplementations(method1, method2);
    }
    else if (method1 == nil && method2 != nil) {
        // Class does not define selector1
        
        // Now get the method with class_getInstanceMethod (as we want to copy its IMP to selector2)
        method1 = class_getInstanceMethod(self, selector1);
        
        class_addMethod(self, selector1, method_getImplementation(method2), method_getTypeEncoding(method2));
        method_setImplementation(method2, method_getImplementation(method1));
    }
    else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"The class \"%@\" does not have an instance method named \"%@\".", self, NSStringFromSelector(selector2)] userInfo:nil];
    }
}

@end
