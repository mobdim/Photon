//
//  PXNavigationController.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationController.h"
#import "PXNavigationBar.h"
#import "PXNavigationItem.h"

#import "PXViewController.h"
#import "PXViewController_Private.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>


@interface PXNavigationController ()

- (void)adjustNavigationBarPositionAnimated:(BOOL)isAnimated;
- (void)replaceView:(NSView *)oldView withView:(NSView *)newView push:(BOOL)shouldPush animated:(BOOL)isAnimated;

@end


@interface NSViewController (PXNavigationControllerPrivate)

@property (nonatomic, strong, readwrite) PXNavigationController *navigationController;

@end


@implementation PXNavigationController {
    NSMutableArray *_viewControllers;
    
    NSView *_containerView;
    PXNavigationBar *_navigationBar;
    
    BOOL _automaticallyHidesNavigationBar;
    BOOL _navigationBarHidden;
}

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
        [self setView:view];
        
        _viewControllers = [NSMutableArray array];
        
        [[self view] setFrameSize:NSMakeSize(280.0, 360.0)];
        [[self view] setWantsLayer:YES];
        
        NSRect bounds = [[self view] bounds];
        _navigationBar = [[PXNavigationBar alloc] initWithFrame:NSMakeRect(0.0, NSMaxY(bounds) - 32.0, NSWidth(bounds), 32.0)];
        _navigationBar.autoresizingMask = (NSViewWidthSizable|NSViewMinYMargin);
        _navigationBar.delegate = self;
        [[self view] addSubview:_navigationBar];
        
        _containerView = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, NSWidth(bounds), NSHeight(bounds) - 32.0)];
        _containerView.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
        [[self view] addSubview:_containerView];
    }
    return self;
}

- (id)initWithRootViewController:(NSViewController *)viewController {
    self = [self init];
    if (self) {
        viewController.navigationController = self;
        [_viewControllers addObject:viewController];
        
        NSSize requiredContentSize = [[viewController view] frame].size;
        
        CGFloat barHeight = [_navigationBar frame].size.height;
        requiredContentSize.height += barHeight;
        
        [[self view] setFrameSize:requiredContentSize];
        
        [_navigationBar pushNavigationItem:[viewController navigationItem] animated:NO];
        
        NSView *newView = [viewController view];
        [newView setFrame:[_containerView bounds]];
        newView.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
        [_containerView setSubviews:@[newView]];
        
        // Set up views and animations
        [self adjustNavigationBarPositionAnimated:NO];
    }
    return self;
}

- (void)adjustNavigationBarPositionAnimated:(BOOL)isAnimated {
    id navigationBarProxy = ([[[self view] window] isVisible] && isAnimated ? [_navigationBar animator] : _navigationBar);
    id containerViewProxy = ([[[self view] window] isVisible] && isAnimated ? [_containerView animator] : _containerView);
    
    [NSAnimationContext beginGrouping];
    
    NSAnimationContext *context = [NSAnimationContext currentContext];
    context.duration = 0.35;
    context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    if (([_viewControllers count] <= 1 && _automaticallyHidesNavigationBar == YES) || _navigationBarHidden) {
        [navigationBarProxy setFrameOrigin:NSMakePoint(0.0, NSMaxY([[self view] bounds]))];
        [containerViewProxy setFrame:[[self view] bounds]];
    }
    else {
        NSPoint newNavBarOrigin = NSMakePoint(0.0, NSMaxY([[self view] bounds]) - [_navigationBar frame].size.height);
        [navigationBarProxy setFrameOrigin:newNavBarOrigin];
        
        NSRect newFrame = [[self view] bounds];
        newFrame.size.height -= [_navigationBar frame].size.height;
        [containerViewProxy setFrame:newFrame];
    }
    
    [NSAnimationContext endGrouping];
}


#pragma mark -
#pragma mark Overrides

- (PXNavigationController *)navigationController {
    return self;
}

- (void)setNavigationController:(PXNavigationController *)controller {
    // no-op
}


#pragma mark -
#pragma mark Events

- (void)swipeWithEvent:(NSEvent *)event {
    if ([event deltaX] == -1.0) {
        [self popViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark Accessors

- (PXNavigationBar *)navigationBar {
    if (_navigationBar == nil) {
        [self view];
    }
    return _navigationBar;
}

- (void)setNavigationBar:(PXNavigationBar *)newNavigationBar {
    if (_navigationBar != newNavigationBar) {
        [self willChangeValueForKey:@"navigationBar"];
        _navigationBar = newNavigationBar;
        [self didChangeValueForKey:@"navigationBar"];
    }
}

- (BOOL)automaticallyHidesNavigationBar {
    return _automaticallyHidesNavigationBar;
}

- (void)setAutomaticallyHidesNavigationBar:(BOOL)automaticallyHidesNavigationBar {
    [self setAutomaticallyHidesNavigationBar:automaticallyHidesNavigationBar animated:NO];
}

- (void)setAutomaticallyHidesNavigationBar:(BOOL)automaticallyHidesNavigationBar animated:(BOOL)isAnimated {
    if (_automaticallyHidesNavigationBar != automaticallyHidesNavigationBar) {
        [self willChangeValueForKey:@"automaticallyHidesNavigationBar"];
        
        _automaticallyHidesNavigationBar = automaticallyHidesNavigationBar;
        
        [self adjustNavigationBarPositionAnimated:isAnimated];
        
        [self didChangeValueForKey:@"automaticallyHidesNavigationBar"];
    }
}

+ (NSSet *)keyPathsForValuesAffectingNavigationBarHidden {
    return [NSSet setWithObjects:@"automaticallyHidesNavigationBar", nil];
}

- (BOOL)isNavigationBarHidden {
    return _navigationBarHidden || ([_viewControllers count] <= 1 && _automaticallyHidesNavigationBar);
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)isAnimated {
    [self willChangeValueForKey:@"navigationBarHidden"];
    _navigationBarHidden = navigationBarHidden;
    [self didChangeValueForKey:@"navigationBarHidden"];
}


#pragma mark -
#pragma mark View Controllers

- (NSArray *)viewControllers {
    return [_viewControllers copy];
}

- (void)setViewControllers:(NSArray *)newArray {
    [self setViewControllers:newArray animated:NO];
}

- (void)setViewControllers:(NSArray *)array animated:(BOOL)isAnimated {
    if (![_viewControllers isEqualToArray:array]) {
        [self willChangeValueForKey:@"viewControllers"];
        
        NSViewController *currentTopController = [_viewControllers lastObject];
        NSViewController *newTopController = [array lastObject];
        
        [self adjustNavigationBarPositionAnimated:isAnimated];
        
        if (currentTopController != nil && newTopController != nil) {
            [self replaceView:[currentTopController view] withView:[newTopController view] push:NO animated:isAnimated];
        }
        else if (currentTopController != nil) {
            if (isAnimated) {
                [[[currentTopController view] animator] removeFromSuperview];
            }
            else {
                [[currentTopController view] removeFromSuperview];
            }
        }
        else if (newTopController != nil) {
            [[newTopController view] setFrame:[_containerView bounds]];
            if (isAnimated) {
                [[_containerView animator] setSubviews:[NSArray arrayWithObject:[newTopController view]]];
            }
            else {
                [_containerView setSubviews:[NSArray arrayWithObject:[newTopController view]]];
            }
        }
        
        for (NSViewController *controller in _viewControllers) {
            [controller setNavigationController:nil];
            
            [controller willMoveToParentViewController:nil];
            [controller removeFromParentViewController];
            [controller didMoveToParentViewController:nil];
        }
        
        [_viewControllers removeAllObjects];
        [_viewControllers setArray:array];
        
        for (NSViewController *controller in _viewControllers) {
            [controller setNavigationController:self];
            [self addChildViewController:controller];
        }
        
        NSMutableArray *navigationBarItems = [NSMutableArray array];
        for (NSViewController *viewController in array) {
            [navigationBarItems addObject:[viewController navigationItem]];
        }
        [_navigationBar setItems:navigationBarItems];
        
        [self didChangeValueForKey:@"viewControllers"];
    }
}

+ (NSSet *)keyPathsForValuesAffectingTopViewController {
    return [NSSet setWithObjects:@"viewControllers", nil];
}

- (NSViewController *)topViewController {
    return [_viewControllers lastObject];
}

- (void)replaceView:(NSView *)oldView withView:(NSView *)newView push:(BOOL)shouldPush animated:(BOOL)isAnimated {
    if ([[[oldView window] firstResponder] isKindOfClass:[NSView class]] && [(NSView *)[[oldView window] firstResponder] isDescendantOf:oldView]) {
        [[oldView window] makeFirstResponder:nil];
    }
    
    if (isAnimated) {
        NSRect oldViewFrameResult = [_containerView bounds];
        if (shouldPush) {
            oldViewFrameResult.origin.x -= oldViewFrameResult.size.width;
        }
        else {
            oldViewFrameResult.origin.x += oldViewFrameResult.size.width;
        }
        
        
        NSRect newViewTempRect = [_containerView bounds];
        if (shouldPush) {
            newViewTempRect.origin.x += newViewTempRect.size.width;
        }
        else {
            newViewTempRect.origin.x -= newViewTempRect.size.width;
        }
        [newView setFrame:newViewTempRect];
        [_containerView addSubview:newView];
        
        NSRect newViewFrameResult = [_containerView bounds];
        
        
        [NSAnimationContext beginGrouping];
        
        NSAnimationContext *context = [NSAnimationContext currentContext];
        context.duration = 0.35;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        context.completionHandler = ^{
            [oldView removeFromSuperview];
        };
        
        [[oldView animator] setFrame:oldViewFrameResult];
        [[newView animator] setFrame:newViewFrameResult];
        
        [NSAnimationContext endGrouping];
    }
    else {
        [newView setFrame:[_containerView bounds]];
        [oldView removeFromSuperview];
        [_containerView addSubview:newView];
    }
}

- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)isAnimated {
    [self willChangeValueForKey:@"viewControllers"];
    
    [_viewControllers addObject:viewController];
    
    [viewController setNavigationController:self];
    [self addChildViewController:viewController];
    
    [_navigationBar pushNavigationItem:[viewController navigationItem] animated:isAnimated];
    
    [self adjustNavigationBarPositionAnimated:isAnimated];
    
    NSView *oldView = [[_containerView subviews] lastObject];
    [self replaceView:oldView withView:[viewController view] push:YES animated:isAnimated];
    
    [self didChangeValueForKey:@"viewControllers"];
}

- (void)popViewControllerAnimated:(BOOL)isAnimated {
    if ([_viewControllers count] > 1) {
        NSViewController *nextController = [_viewControllers objectAtIndex:[_viewControllers count]-2];
        
        NSViewController *topController = [self topViewController];
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
            [[self delegate] navigationController:self willShowViewController:nextController animated:isAnimated];
        }
        
        [self willChangeValueForKey:@"viewControllers"];
        
        [topController setNavigationController:nil];
        
        [topController willMoveToParentViewController:nil];
        [topController removeFromParentViewController];
        [topController didMoveToParentViewController:nil];
        
        [_viewControllers removeObjectAtIndex:[_viewControllers count]-1];
        
        [self adjustNavigationBarPositionAnimated:isAnimated];
        
        [self replaceView:[topController view] withView:[nextController view] push:NO animated:isAnimated];
        
        [_navigationBar popNavigationItemAnimated:isAnimated];
        
        [self didChangeValueForKey:@"viewControllers"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [[self delegate] navigationController:self didShowViewController:nextController animated:isAnimated];
        }
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)isAnimated {
    NSViewController *rootController = (([_viewControllers count] > 0) ? [_viewControllers objectAtIndex:0] : nil);
    NSViewController *topController = [_viewControllers lastObject];
    
    if (rootController != nil && rootController != topController) {
        NSArray *viewControllersToPop = [_viewControllers subarrayWithRange:NSMakeRange(1, [_viewControllers count]-1)];
        if ([[self delegate] respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
            [[self delegate] navigationController:self willShowViewController:rootController animated:isAnimated];
        }
        
        [self willChangeValueForKey:@"viewControllers"];
        
        for (NSViewController *viewController in viewControllersToPop) {
            [viewController setNavigationController:nil];
            
            [viewController willMoveToParentViewController:nil];
            [viewController removeFromParentViewController];
            [viewController didMoveToParentViewController:nil];
        }
        
        [_viewControllers removeObjectsInRange:NSMakeRange(1, [_viewControllers count]-1)];
        
        [self replaceView:[topController view] withView:[rootController view] push:NO animated:isAnimated];
        
        [_navigationBar popToRootNavigationItemAnimated:isAnimated];
        
        [self adjustNavigationBarPositionAnimated:isAnimated];
        
        [self didChangeValueForKey:@"viewControllers"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [[self delegate] navigationController:self didShowViewController:rootController animated:isAnimated];
        }
    }
}

- (void)popToViewController:(NSViewController *)viewController animated:(BOOL)isAnimated updateNavigationBar:(BOOL)updateNavigationBar {
    NSViewController *topController = [_viewControllers lastObject];
    
    NSInteger index = [_viewControllers indexOfObjectIdenticalTo:viewController];
    if (index != NSNotFound && viewController != nil && viewController != topController) {
        NSArray *viewControllersToPop = [_viewControllers subarrayWithRange:NSMakeRange(index+1, [_viewControllers count]-(index+1))];
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
            [[self delegate] navigationController:self willShowViewController:viewController animated:isAnimated];
        }
        
        [self willChangeValueForKey:@"viewControllers"];
        
        for (NSViewController *viewController in viewControllersToPop) {
            [viewController setNavigationController:nil];
            
            [viewController willMoveToParentViewController:nil];
            [viewController removeFromParentViewController];
            [viewController didMoveToParentViewController:nil];
        }
        
        [_viewControllers removeObjectsInRange:NSMakeRange(index+1, [_viewControllers count]-(index+1))];
        
        [self replaceView:[topController view] withView:[viewController view] push:NO animated:isAnimated];
        
        if (updateNavigationBar) {
            [_navigationBar popToNavigationItem:[viewController navigationItem] animated:isAnimated];
        }
        
        [self adjustNavigationBarPositionAnimated:isAnimated];
        
        [self didChangeValueForKey:@"viewControllers"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [[self delegate] navigationController:self didShowViewController:viewController animated:isAnimated];
        }
    }
}

- (void)popToViewController:(NSViewController *)viewController animated:(BOOL)isAnimated {
    [self popToViewController:viewController animated:isAnimated updateNavigationBar:YES];
}


#pragma mark -
#pragma mark Navigation Bar delegate

- (BOOL)navigationBar:(PXNavigationBar *)bar shouldPushItem:(PXNavigationItem *)item {
    return YES;
}

- (void)navigationBar:(PXNavigationBar *)bar didPushItem:(PXNavigationItem *)item {
    
}

- (BOOL)navigationBar:(PXNavigationBar *)bar shouldPopItem:(PXNavigationItem *)item {
    return YES;
}

- (void)navigationBar:(PXNavigationBar *)bar didPopItem:(PXNavigationItem *)item {
    PXNavigationItem *newItem = [bar topItem];
    NSViewController *viewController = [newItem representedObject];
    [self popToViewController:viewController animated:YES updateNavigationBar:NO];
}

@end


@implementation NSViewController (PXNavigationController)

static NSString * const PXViewControllerNavigationControllerKey = @"PXViewControllerNavigationController";
static NSString * const PXViewControllerNavigationItemKey = @"PXViewControllerNavigationItem";

- (PXNavigationController *)navigationController {
    PXNavigationController *controller = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerNavigationControllerKey);
    if (controller == nil) {
        NSViewController *parent = self.parentViewController;
        while (parent != nil && controller == nil) {
            controller = parent.navigationController;
            parent = parent.parentViewController;
        }
    }
    return controller;
}

- (void)setNavigationController:(PXNavigationController *)controller {
    PXNavigationController *currentNavigationController = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerNavigationControllerKey);
    if (currentNavigationController != controller) {
        [self willChangeValueForKey:@"navigationController"];
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerNavigationControllerKey, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"navigationController"];
    }
}

- (PXNavigationItem *)navigationItem {
    PXNavigationItem *navigationItem = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerNavigationItemKey);
    if (navigationItem == nil) {
        navigationItem = [[PXNavigationItem alloc] init];
        [navigationItem bind:NSTitleBinding toObject:self withKeyPath:@"title" options:nil];
        //[navigationItem bind:NSImageBinding toObject:self withKeyPath:@"image" options:nil];
        [navigationItem setRepresentedObject:self];
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerNavigationItemKey, navigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return navigationItem;
}

@end
