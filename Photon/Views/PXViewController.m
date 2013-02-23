//
//  PXViewController.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXViewController.h"
#import "PXViewController_Private.h"

#import "NSObject+PhotonAdditions.h"
#import <objc/runtime.h>


@interface PXViewControllerProxy : NSObject

@property (nonatomic, weak) id object;

@end


@implementation NSViewController (PXViewController)

+ (void)px_installViewControllerSupport {
    if (self == [NSViewController class]) {
        [NSView px_installViewControllerSupport];
        [NSPopover px_installViewControllerSupport];
        
        [self px_exchangeInstanceMethodForSelector:@selector(setView:) withSelector:@selector(px_setView:)];
    }
}


#pragma mark -
#pragma mark Accessors

- (void)px_setView:(NSView *)aView {
    [self px_setView:aView];
    if (aView != nil) {
        [aView px_setViewController:self];
    }
}

static NSString * const PXViewControllerParentViewControllerKey = @"PXViewControllerParentViewController";

- (NSViewController *)parentViewController {
    PXViewControllerProxy *proxy = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerParentViewControllerKey);
    return proxy.object;
}

- (void)setParentViewController:(NSViewController *)aViewController {
    NSViewController *currentController = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerParentViewControllerKey);
    if (currentController != aViewController) {
        PXViewControllerProxy *proxy = [[PXViewControllerProxy alloc] init];
        proxy.object = aViewController;
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerParentViewControllerKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

static NSString * const PXViewControllerContentSizeForViewInPopoverKey = @"PXViewControllerContentSizeForViewInPopover";

- (NSSize)contentSizeForViewInPopover {
    NSValue *value = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerContentSizeForViewInPopoverKey);
    if (value != nil) {
        return [value sizeValue];
    }
    return NSMakeSize(320.0, 480.0);
}

- (void)setContentSizeForViewInPopover:(NSSize)contentSizeForViewInPopover {
    objc_setAssociatedObject(self, (__bridge void *)PXViewControllerContentSizeForViewInPopoverKey, [NSValue valueWithSize:contentSizeForViewInPopover], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static NSString * const PXViewControllerPopoverKey = @"PXViewControllerPopover";

- (NSPopover *)popover {
    PXViewControllerProxy *proxy = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerPopoverKey);
    return proxy.object;
}

- (void)setPopover:(NSPopover *)popover {
    PXViewControllerProxy *proxy = [[PXViewControllerProxy alloc] init];
    proxy.object = popover;
    objc_setAssociatedObject(self, (__bridge void *)PXViewControllerPopoverKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

@end


@implementation NSView (PXViewController)

+ (void)px_installViewControllerSupport {
    if (self == [NSView class]) {
        [self px_exchangeInstanceMethodForSelector:@selector(setNextResponder:) withSelector:@selector(px_setNextResponder:)];
    }
}


#pragma mark -
#pragma mark Accessors

static NSString * const PXViewControllerKey = @"PXViewController";

- (NSViewController *)px_viewController {
    PXViewControllerProxy *proxy = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerKey);
    return proxy.object;
}

- (void)px_setViewController:(NSViewController *)viewController {
    NSViewController *currentController = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerKey);
    if (currentController != viewController) {
        if (currentController != nil) {
            NSResponder *nextResponder = [currentController nextResponder];
            [self px_setNextResponder:nextResponder];
            [currentController setNextResponder:nil];
        }
        
        PXViewControllerProxy *proxy = [[PXViewControllerProxy alloc] init];
        proxy.object = viewController;
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (viewController != nil) {
            NSResponder *nextResponder = [self nextResponder];
            [self px_setNextResponder:viewController];
            [viewController setNextResponder:nextResponder];
        }
    }
}

- (void)px_setNextResponder:(NSResponder *)responder {
    if ([self px_viewController] != nil) {
        [[self px_viewController] setNextResponder:responder];
    }
    else {
        [self px_setNextResponder:responder];
    }
}

@end


@implementation NSPopover (PXViewController)

+ (void)px_installViewControllerSupport {
    if (self == [NSPopover class]) {
        [self px_exchangeInstanceMethodForSelector:@selector(setContentViewController:) withSelector:@selector(px_setContentViewController:)];
    }
}

- (void)px_setContentViewController:(NSViewController *)viewController {
    self.contentViewController.popover = nil;
    [self px_setContentViewController:viewController];
    viewController.popover = self;
}

@end


@implementation PXViewControllerProxy

@end
