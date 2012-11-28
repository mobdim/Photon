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

@end


@interface PXAppearanceProxy : NSProxy

+ (id)proxyWithTargetClass:(Class)targetClass containerClasses:(NSArray *)containerClasses;

@property (nonatomic, unsafe_unretained) Class targetClass;
@property (nonatomic, strong) NSArray *containerClasses;

@end


@implementation NSView (PXAppearance)

+ (id)appearance {
    return [self appearanceWhenContainedIn:[NSView class], nil];
}

+ (id)appearanceWhenContainedIn:(Class <PXAppearanceContainer>)containerClass, ... {
    NSMutableArray *containerClasses = [NSMutableArray array];
    
    va_list args;
    va_start(args, containerClass);
    for (Class aClass = containerClass; aClass != Nil; aClass = va_arg(args, Class)) {
        if ([aClass conformsToProtocol:@protocol(PXAppearanceContainer)]) {
            [containerClasses addObject:aClass];
        }
        else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not conform to PXAppearanceContainer", NSStringFromClass(aClass)] userInfo:nil];
        }
    }
    va_end(args);
    
    return [PXAppearanceProxy proxyWithTargetClass:self containerClasses:containerClasses];
}

@end


@implementation PXAppearanceCoordinator

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
        
    }
    return self;
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
    
}

@end
