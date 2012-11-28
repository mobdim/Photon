//
//  PXViewController.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXViewController.h"
#import "PXViewController_Private.h"

#import <objc/runtime.h>


@interface NSView (PXViewControllerPrivate)

@property (nonatomic, weak) NSViewController *viewController;

@end


@implementation NSViewController (PXViewController)

+ (void)px_installViewControllerSupport {
    if (self == [NSViewController class]) {
        Method oldMethod = class_getInstanceMethod([NSView class], @selector(forwardingTargetForSelector:));
        Method newMethod = class_getInstanceMethod([NSView class], @selector(px_forwardingTargetForSelector:));
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

#pragma mark -
#pragma mark Appearance / Disappearance

- (void)viewWillAppear {
    // Overridden by subclasses
}

- (void)viewDidAppear {
    // Overridden by subclasses
}

- (void)viewWillDisappear {
    // Overridden by subclasses
}

- (void)viewDidDisappear {
    // Overridden by subclasses
}


#pragma mark -
#pragma mark Accessors

static NSString * const PXViewControllerParentViewControllerKey = @"PXViewControllerParentViewController";

- (NSViewController *)parentViewController {
    return objc_getAssociatedObject(self, (__bridge void *)PXViewControllerParentViewControllerKey);
}

- (void)setParentViewController:(NSViewController *)aViewController {
    NSViewController *currentController = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerParentViewControllerKey);
    if (currentController != aViewController) {
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerParentViewControllerKey, aViewController, OBJC_ASSOCIATION_ASSIGN);
    }
}

@end


@implementation NSView (PXViewController)

#pragma mark -
#pragma mark Accessors

static NSString * const PXViewControllerKey = @"PXViewController";

- (NSViewController *)viewController {
    return objc_getAssociatedObject(self, (__bridge void *)PXViewControllerKey);
}

- (void)setViewController:(NSViewController *)viewController {
    NSViewController *currentController = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerKey);
    if (currentController != viewController) {
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerKey, viewController, OBJC_ASSOCIATION_ASSIGN);
    }
}


#pragma mark -
#pragma mark Events

- (id)px_forwardingTargetForSelector:(SEL)aSelector {
    if ([self.viewController respondsToSelector:aSelector]) {
        return self.viewController;
    }
    return [self px_forwardingTargetForSelector:aSelector];
}

@end
