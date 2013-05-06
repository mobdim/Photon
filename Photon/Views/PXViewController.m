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


@implementation NSViewController (PXViewController)

+ (void)px_installViewControllerSupport {
    if (self == [NSViewController class]) {
        [NSView px_installViewControllerSupport];
        
        [self px_exchangeInstanceMethodForSelector:@selector(view) withSelector:@selector(px_view)];
        [self px_exchangeInstanceMethodForSelector:@selector(setView:) withSelector:@selector(px_setView:)];
        [self px_exchangeInstanceMethodForSelector:@selector(loadView) withSelector:@selector(px_loadView)];
    }
}


#pragma mark -
#pragma mark Accessors

static NSString * const PXViewDidLoadInvokedKey = @"PXViewDidLoadInvoked";

- (NSView *)px_view {
    NSView *value = [self px_view];
    NSNumber *viewDidLoadInvoked = objc_getAssociatedObject(self, (__bridge void *)PXViewDidLoadInvokedKey);
    if (viewDidLoadInvoked == nil) {
        objc_setAssociatedObject(self, (__bridge void *)PXViewDidLoadInvokedKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self viewDidLoad];
    }
    return value;
}

- (void)px_setView:(NSView *)aView {
    [self px_setView:aView];
    if (aView != nil) {
        [aView px_setViewController:self];
    }
}

- (void)px_loadView {
    NSString *nibName = [self nibName];
    if (nibName == nil) {
        self.view = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
    }
    else {
        [self px_loadView];
    }
}

- (void)viewDidLoad {
    
}


#pragma mark -
#pragma mark Appearance / Disappearance

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
}


#pragma mark -
#pragma mark Container View Controllers

static NSString * const PXViewControllerParentViewControllerKey = @"PXViewControllerParentViewController";
static NSString * const PXViewControllerChildViewControllersKey = @"PXViewControllerChildViewControllers";

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

- (NSMutableArray *)px_childViewControllers {
    NSMutableArray *array = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerChildViewControllersKey);
    if (array == nil) {
        array = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerChildViewControllersKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

- (void)addChildViewController:(NSViewController *)childController {
    if ([childController parentViewController] != nil) {
        [childController willMoveToParentViewController:nil];
        [childController removeFromParentViewController];
        [childController didMoveToParentViewController:nil];
    }
    
    [childController willMoveToParentViewController:self];
    [[self px_childViewControllers] addObject:childController];
    childController.parentViewController = self;
}

- (void)removeChildViewController:(NSViewController *)childController {
    [[self px_childViewControllers] removeObject:childController];
    childController.parentViewController = nil;
}

- (void)removeFromParentViewController {
    [self.parentViewController removeChildViewController:self];
    [self didMoveToParentViewController:nil];
}

- (void)willMoveToParentViewController:(NSViewController *)parent {
//    BOOL animated = [[self view] window] != nil;
//    if (parent != nil) {
//        [self viewWillAppear:animated];
//    }
//    else {
//        [self viewWillDisappear:animated];
//    }
}

- (void)didMoveToParentViewController:(NSViewController *)parent {
//    BOOL animated = [[self view] window] != nil;
//    if (parent != nil) {
//        [self viewDidAppear:animated];
//    }
//    else {
//        [self viewDidDisappear:animated];
//    }
}

@end


@implementation NSView (PXViewController)

+ (void)px_installViewControllerSupport {
    if (self == [NSView class]) {
        [self px_exchangeInstanceMethodForSelector:@selector(setNextResponder:) withSelector:@selector(px_setNextResponder:)];
        [self px_exchangeInstanceMethodForSelector:@selector(viewWillMoveToWindow:) withSelector:@selector(px_viewWillMoveToWindow:)];
        [self px_exchangeInstanceMethodForSelector:@selector(viewDidMoveToWindow) withSelector:@selector(px_viewDidMoveToWindow)];
    }
}


#pragma mark -
#pragma mark View Hierarchy

static NSString * const PXViewIsAppearingKey = @"PXViewIsAppearing";
static NSString * const PXViewIsDisappearingKey = @"PXViewIsDisappearing";

- (void)px_viewWillMoveToWindow:(NSWindow *)window {
    if ([self window] != nil && window == nil) {
        [[self px_viewController] viewWillDisappear:YES];
        objc_setAssociatedObject(self, (__bridge void *)PXViewIsDisappearingKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        objc_setAssociatedObject(self, (__bridge void *)PXViewIsDisappearingKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if ([self window] == nil && window != nil) {
        [[self px_viewController] viewWillAppear:YES];
        objc_setAssociatedObject(self, (__bridge void *)PXViewIsAppearingKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        objc_setAssociatedObject(self, (__bridge void *)PXViewIsAppearingKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self px_viewWillMoveToWindow:window];
}

- (void)px_viewDidMoveToWindow {
    [self px_viewDidMoveToWindow];
    
    if ([objc_getAssociatedObject(self, (__bridge void *)PXViewIsDisappearingKey) boolValue]) {
        [[self px_viewController] viewDidDisappear:YES];
    }
    if ([objc_getAssociatedObject(self, (__bridge void *)PXViewIsAppearingKey) boolValue]) {
        [[self px_viewController] viewDidAppear:YES];
    }
    
    objc_setAssociatedObject(self, (__bridge void *)PXViewIsDisappearingKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, (__bridge void *)PXViewIsAppearingKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -
#pragma mark Accessors

static NSString * const PXViewControllerKey = @"PXViewController";

- (NSViewController *)px_viewController {
    PXViewControllerProxy *proxy = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerKey);
    return proxy.object;
}

- (void)px_setViewController:(NSViewController *)viewController {
    PXViewControllerProxy *proxy = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerKey);
    NSViewController *currentController = proxy.object;
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


@implementation PXViewControllerProxy

@end


@implementation NSWindow (PXViewController)

static NSString * const PXRootViewControllerKey = @"PXRootViewController";

- (NSViewController *)rootViewController {
    return objc_getAssociatedObject(self, (__bridge void *)PXRootViewControllerKey);
}

- (void)setRootViewController:(NSViewController *)rootViewController {
    NSViewController *currentController = objc_getAssociatedObject(self, (__bridge void *)PXRootViewControllerKey);
    if (currentController != rootViewController) {
        BOOL animated = [self isVisible];
        
        if (currentController != nil) {
            [rootViewController viewWillDisappear:animated];
            
            [[currentController view] removeFromSuperview];
            [currentController setNextResponder:nil];
            
            [rootViewController viewDidDisappear:animated];
        }
        
        objc_setAssociatedObject(self, (__bridge void *)PXRootViewControllerKey, rootViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (rootViewController != nil) {;
            [rootViewController setNextResponder:self];
            
            [rootViewController viewWillAppear:animated];
            
            NSView *view = [rootViewController view];
            view.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
            [self.contentView setSubviews:@[view]];
            
            [rootViewController viewDidAppear:animated];
        }
    }
}

@end
