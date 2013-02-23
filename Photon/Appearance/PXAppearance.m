//
//  PXAppearance.m
//  Photon
//
//  Created by Logan Collins on 11/27/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXAppearance.h"

#import <objc/runtime.h>


@interface PXAppearanceCoordinator : NSObject

+ (PXAppearanceCoordinator *)sharedCoordinator;

- (void)registerInvocation:(NSInvocation *)invocation targetClass:(Class)targetClass containerClasses:(NSArray *)containerClasses;
- (NSArray *)invocationsForView:(NSView *)view;

@end


@interface PXAppearanceProxy : NSProxy

+ (id)proxyWithTargetClass:(Class)targetClass containerClasses:(NSArray *)containerClasses;

@property (nonatomic, unsafe_unretained) Class targetClass;
@property (nonatomic, strong) NSArray *containerClasses;

@end


@implementation NSView (PXAppearance)

+ (void)px_installAppearanceMethods {
    // Replace some methods on NSView to support appearance proxies
//    Method originalMethod = class_getInstanceMethod(self, @selector(viewWillMoveToSuperview:));
//    Method newMethod = class_getInstanceMethod(self, @selector(px_viewWillMoveToSuperview:));
//    method_exchangeImplementations(originalMethod, newMethod);
}

+ (id)px_appearance {
    return [self px_appearanceWhenContainedIn:nil];
}

+ (id)px_appearanceWhenContainedIn:(Class <PXAppearanceContainer>)containerClass, ... {
    NSMutableArray *containerClasses = [NSMutableArray array];
    
    va_list args;
    va_start(args, containerClass);
    for (Class aClass = containerClass; aClass != Nil; aClass = va_arg(args, Class)) {
        if (!class_isMetaClass(object_getClass(aClass))) {
            // Not a class object
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ is not a class object", aClass] userInfo:nil];
        }
        else if (![aClass conformsToProtocol:@protocol(PXAppearanceContainer)]) {
            // Does not conform to PXAppearanceContainer
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not conform to PXAppearanceContainer", NSStringFromClass(aClass)] userInfo:nil];
        }
        else {
            [containerClasses addObject:aClass];
        }
    }
    va_end(args);
    
    return [PXAppearanceProxy proxyWithTargetClass:self containerClasses:containerClasses];
}

//- (void)px_viewWillMoveToSuperview:(NSView *)newSuperview {
//    // Invoke appearance customization methods
//    NSArray *invocations = [[PXAppearanceCoordinator sharedCoordinator] invocationsForView:self];
//    for (NSInvocation *invocation in invocations) {
//        [invocation invokeWithTarget:self];
//    }
//    
//    [self px_viewWillMoveToSuperview:newSuperview];
//}

@end


@implementation NSViewController (PXAppearance) @end


@implementation PXAppearanceCoordinator {
    NSMapTable *_invocations;
}

+ (void)initialize {
    if (self == [PXAppearanceCoordinator class]) {
        [NSView px_installAppearanceMethods];
    }
}

+ (PXAppearanceCoordinator *)sharedCoordinator {
    static PXAppearanceCoordinator *sharedCoordinator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCoordinator = [[self alloc] init];
    });
    return sharedCoordinator;
}

- (id)init {
    self = [super init];
    if (self) {
        _invocations = [NSMapTable mapTableWithStrongToStrongObjects];
    }
    return self;
}

- (void)registerInvocation:(NSInvocation *)invocation targetClass:(Class)targetClass containerClasses:(NSArray *)containerClasses {
    NSMutableArray *targetClassInvocations = [_invocations objectForKey:targetClass];
    if (targetClassInvocations == nil) {
        targetClass = [NSMutableArray array];
        [_invocations setObject:targetClassInvocations forKey:targetClass];
    }
    
    
}

- (NSArray *)invocationsForView:(NSView *)view {
    NSMutableArray *invocations = [NSMutableArray array];
    
    Class targetClass = [view class];
    while ([targetClass conformsToProtocol:@protocol(PXAppearance)]) {
        
        
        targetClass = [targetClass superclass];
    }
    
    return invocations;
}

@end


@implementation PXAppearanceProxy

@synthesize targetClass=_targetClass;
@synthesize containerClasses=_containerClasses;

+ (id)proxyWithTargetClass:(Class)targetClass containerClasses:(NSArray *)containerClasses {
    PXAppearanceProxy *proxy = [[self alloc] init];
    proxy.targetClass = targetClass;
    proxy.containerClasses = containerClasses;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [[self targetClass] instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSMethodSignature *methodSignature = [anInvocation methodSignature];
    
    // Ensure the return type is void
    const char * returnType = [methodSignature methodReturnType];
    if (strcmp(returnType, @encode(void)) != 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Appearance proxy invocations must have a void return type." userInfo:nil];
    }
    
    // Retain arguments
    [anInvocation setTarget:nil];
    [anInvocation retainArguments];
    
    [[PXAppearanceCoordinator sharedCoordinator] registerInvocation:anInvocation targetClass:self.targetClass containerClasses:self.containerClasses];
}

@end
