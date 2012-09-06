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


@interface PXNavigationController () <NSAnimationDelegate>

- (void)adjustNavigationBarPositionAnimated:(BOOL)isAnimated;
- (void)replaceView:(NSView *)oldView withView:(NSView *)newView push:(BOOL)shouldPush animated:(BOOL)isAnimated;

@end


@interface PXViewController (PXNavigationControllerPrivate)

@property (nonatomic, strong, readwrite) PXNavigationController *navigationController;

@end


@implementation PXNavigationController {
    NSMutableArray *_viewControllers;
    
    NSView *_containerView;
    PXNavigationBar *_navigationBar;
    
    NSAnimation *_currentAnimation;
    NSView *_disappearingView;
    
    BOOL _automaticallyHidesNavigationBar;
    BOOL _navigationBarHidden;
}

- (id)init {
    self = [super init];
    if (self) {
        _viewControllers = [[NSMutableArray alloc] init];
        
        NSRect bounds = [[self view] bounds];
        _navigationBar = [[PXNavigationBar alloc] initWithFrame:NSMakeRect(0.0, NSMaxY(bounds) - 25.0, NSWidth(bounds), 25.0)];
        _navigationBar.autoresizingMask = (NSViewWidthSizable|NSViewMinYMargin);
        [[self view] addSubview:_navigationBar];
        
        _containerView = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, NSWidth(bounds), NSHeight(bounds) - 25.0)];
        _containerView.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
        [[self view] addSubview:_containerView];
    }
    return self;
}

- (id)initWithRootViewController:(PXViewController *)viewController {
    self = [self init];
    if (self) {
        viewController.navigationController = self;
        [_viewControllers addObject:viewController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"PXNavigationController cannot be instantiated with %@", NSStringFromSelector(_cmd)] userInfo:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _viewControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Set up navigation bar
    [_navigationBar setDelegate:self];
    
    for (PXViewController *viewController in self.viewControllers) {
        [_navigationBar pushNavigationItem:[viewController navigationItem] animated:NO];
    }
    
    
    // Set up views and animations
    [self adjustNavigationBarPositionAnimated:NO];
    
    
    // Load root view controller
    if ([_viewControllers count] > 0) {
        PXViewController *rootViewController = [_viewControllers objectAtIndex:0];
        NSView *newView = [rootViewController view];
        [newView setFrame:[_containerView bounds]];
        [_containerView setSubviews:[NSArray arrayWithObject:newView]];
    }
}

- (void)adjustNavigationBarPositionAnimated:(BOOL)isAnimated {
    id navigationBarProxy = ([[[self view] window] isVisible] && isAnimated ? [_navigationBar animator] : _navigationBar);
    id containerViewProxy = ([[[self view] window] isVisible] && isAnimated ? [_containerView animator] : _containerView);
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.15];
    
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

- (void)viewWillAppear {
    [[self topViewController] viewWillAppear];
}

- (void)viewDidAppear {
    [[self topViewController] viewDidAppear];
}

- (void)viewWillDisappear {
    [[self topViewController] viewWillDisappear];
}

- (void)viewDidDisappear {
    [[self topViewController] viewDidDisappear];
}

- (PXNavigationController *)navigationController {
    return self;
}

- (void)setNavigationController:(PXNavigationController *)controller {
    // no-op
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
        
        PXViewController *currentTopController = [_viewControllers lastObject];
        PXViewController *newTopController = [array lastObject];
        
        [currentTopController viewWillDisappear];
        [newTopController viewWillAppear];
        
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
        
        for (PXViewController *controller in _viewControllers) {
            [controller setNavigationController:nil];
            [controller setParentViewController:nil];
        }
        
        [_viewControllers removeAllObjects];
        [_viewControllers setArray:array];
        
        for (PXViewController *controller in _viewControllers) {
            [controller setNavigationController:self];
            [controller setParentViewController:self];
        }
        
        NSMutableArray *navigationBarItems = [NSMutableArray array];
        for (PXViewController *viewController in array) {
            [navigationBarItems addObject:[viewController navigationItem]];
        }
        [_navigationBar setItems:navigationBarItems];
        
        [currentTopController viewDidDisappear];
        [newTopController viewDidAppear];
        
        [self didChangeValueForKey:@"viewControllers"];
    }
}

+ (NSSet *)keyPathsForValuesAffectingTopViewController {
    return [NSSet setWithObjects:@"viewControllers", nil];
}

- (PXViewController *)topViewController {
    return [_viewControllers lastObject];
}

- (void)replaceView:(NSView *)oldView withView:(NSView *)newView push:(BOOL)shouldPush animated:(BOOL)isAnimated {
    if ([[[oldView window] firstResponder] isKindOfClass:[NSView class]] && [(NSView *)[[oldView window] firstResponder] isDescendantOf:oldView]) {
        [[oldView window] makeFirstResponder:nil];
    }
    
    if (isAnimated) {
        _disappearingView = oldView;
        
        NSRect oldViewFrameResult = [oldView frame];
        if (shouldPush) {
            oldViewFrameResult.origin.x -= oldViewFrameResult.size.width;
        }
        else {
            oldViewFrameResult.origin.x += oldViewFrameResult.size.width;
        }
        
        
        NSRect newViewTempRect = [oldView frame];
        if (shouldPush) {
            newViewTempRect.origin.x += newViewTempRect.size.width;
        }
        else {
            newViewTempRect.origin.x -= newViewTempRect.size.width;
        }
        [newView setFrame:newViewTempRect];
        [_containerView addSubview:newView];
        
        
        NSDictionary *oldViewDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           oldView, NSViewAnimationTargetKey,
                                           [NSValue valueWithRect:[oldView frame]], NSViewAnimationStartFrameKey,
                                           [NSValue valueWithRect:oldViewFrameResult], NSViewAnimationEndFrameKey,
                                           nil];
        
        NSRect newViewFrameResult = [oldView frame];
        
        NSDictionary *newViewDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           newView, NSViewAnimationTargetKey,
                                           [NSValue valueWithRect:[newView frame]], NSViewAnimationStartFrameKey,
                                           [NSValue valueWithRect:newViewFrameResult], NSViewAnimationEndFrameKey,
                                           nil];
        
        NSArray *animations = [NSArray arrayWithObjects:oldViewDictionary, newViewDictionary, nil];
        
        _currentAnimation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
        [_currentAnimation setDelegate:self];
        [_currentAnimation setAnimationBlockingMode:NSAnimationBlocking];
        [_currentAnimation setDuration:0.25];
        [_currentAnimation setAnimationCurve:NSAnimationEaseInOut];
        [_currentAnimation startAnimation];
    }
    else {
        [newView setFrame:[oldView frame]];
        [oldView removeFromSuperview];
        [_containerView addSubview:newView];
    }
}

- (void)animationDidStop:(NSAnimation *)animation {
    [_disappearingView removeFromSuperview];
    _disappearingView = nil;
    _currentAnimation = nil;
}

- (void)animationDidEnd:(NSAnimation*)animation {
    [_disappearingView removeFromSuperview];
    _disappearingView = nil;
    _currentAnimation = nil;
}

- (void)pushViewController:(PXViewController *)viewController animated:(BOOL)isAnimated {
    if ([[self delegate] respondsToSelector:@selector(navigationController:willPushViewController:animated:)]) {
        [[self delegate] navigationController:self willPushViewController:viewController animated:isAnimated];
    }
    
    [self willChangeValueForKey:@"viewControllers"];
    
    PXViewController *currentViewController = [self topViewController];
    
    [currentViewController viewWillDisappear];
    [viewController viewWillAppear];
    
    [_viewControllers addObject:viewController];
    
    [viewController setNavigationController:self];
    [viewController setParentViewController:self];
    
    [_navigationBar pushNavigationItem:[viewController navigationItem] animated:isAnimated];
    
    [self adjustNavigationBarPositionAnimated:isAnimated];
    
    NSView *oldView = [[_containerView subviews] lastObject];
    [self replaceView:oldView withView:[viewController view] push:YES animated:isAnimated];
    
    [currentViewController viewDidDisappear];
    [viewController viewDidAppear];
    
    [self didChangeValueForKey:@"viewControllers"];
    
    if ([[self delegate] respondsToSelector:@selector(navigationController:didPushViewController:animated:)]) {
        [[self delegate] navigationController:self didPushViewController:viewController animated:isAnimated];
    }
}

- (void)popViewControllerAnimated:(BOOL)isAnimated {
    if ([_viewControllers count] > 1) {
        PXViewController *nextController = [_viewControllers objectAtIndex:[_viewControllers count]-2];
        
        PXViewController *topController = [self topViewController];
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:willPopViewController:animated:)]) {
            [[self delegate] navigationController:self willPopViewController:topController animated:isAnimated];
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
            [[self delegate] navigationController:self willShowViewController:nextController animated:isAnimated];
        }
        
        [self willChangeValueForKey:@"viewControllers"];
        
        [topController viewWillDisappear];
        [nextController viewWillAppear];
        
        [topController setNavigationController:nil];
        [topController setParentViewController:nil];
        
        [_viewControllers removeObjectAtIndex:[_viewControllers count]-1];
        
        [self adjustNavigationBarPositionAnimated:isAnimated];
        
        [self replaceView:[topController view] withView:[nextController view] push:NO animated:isAnimated];
        
        [_navigationBar popNavigationItemAnimated:isAnimated];
        
        [topController viewDidDisappear];
        [nextController viewDidAppear];
        
        [self didChangeValueForKey:@"viewControllers"];
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:didPopViewController:animated:)]) {
            [[self delegate] navigationController:self didPopViewController:topController animated:isAnimated];
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [[self delegate] navigationController:self didShowViewController:nextController animated:isAnimated];
        }
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)isAnimated {
    PXViewController *rootController = (([_viewControllers count] > 0) ? [_viewControllers objectAtIndex:0] : nil);
    PXViewController *topController = [_viewControllers lastObject];
    
    if (rootController != nil && rootController != topController) {
        NSArray *viewControllersToPop = [_viewControllers subarrayWithRange:NSMakeRange(1, [_viewControllers count]-1)];
        for (PXViewController *viewController in viewControllersToPop) {
            if ([[self delegate] respondsToSelector:@selector(navigationController:willPopViewController:animated:)]) {
                [[self delegate] navigationController:self willPopViewController:viewController animated:isAnimated];
            }
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
            [[self delegate] navigationController:self willShowViewController:rootController animated:isAnimated];
        }
        
        [self willChangeValueForKey:@"viewControllers"];
        
        [topController viewWillDisappear];
        [rootController viewWillAppear];
        
        for (PXViewController *viewController in viewControllersToPop) {
            [viewController setNavigationController:nil];
            [viewController setParentViewController:self];
        }
        
        [_viewControllers removeObjectsInRange:NSMakeRange(1, [_viewControllers count]-1)];
        
        [self replaceView:[topController view] withView:[rootController view] push:NO animated:isAnimated];
        
        [_navigationBar popToRootNavigationItemAnimated:isAnimated];
        
        [self adjustNavigationBarPositionAnimated:isAnimated];
        
        [topController viewDidDisappear];
        [rootController viewDidAppear];
        
        [self didChangeValueForKey:@"viewControllers"];
        
        for (PXViewController *viewController in viewControllersToPop) {
            if ([[self delegate] respondsToSelector:@selector(navigationController:didPopViewController:animated:)]) {
                [[self delegate] navigationController:self didPopViewController:viewController animated:isAnimated];
            }
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [[self delegate] navigationController:self didShowViewController:rootController animated:isAnimated];
        }
    }
}

- (void)popToViewController:(PXViewController *)viewController animated:(BOOL)isAnimated updateNavigationBar:(BOOL)updateNavigationBar {
    PXViewController *topController = [_viewControllers lastObject];
    
    NSInteger index = [_viewControllers indexOfObjectIdenticalTo:viewController];
    if (index != NSNotFound && viewController != nil && viewController != topController) {
        NSArray *viewControllersToPop = [_viewControllers subarrayWithRange:NSMakeRange(index+1, [_viewControllers count]-(index+1))];
        for (PXViewController *viewController in viewControllersToPop) {
            if ([[self delegate] respondsToSelector:@selector(navigationController:willPopViewController:animated:)]) {
                [[self delegate] navigationController:self willPopViewController:viewController animated:isAnimated];
            }
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
            [[self delegate] navigationController:self willShowViewController:viewController animated:isAnimated];
        }
        
        [self willChangeValueForKey:@"viewControllers"];
        
        [topController viewWillDisappear];
        [viewController viewWillAppear];
        
        for (PXViewController *viewController in viewControllersToPop) {
            [viewController setNavigationController:nil];
            [viewController setParentViewController:self];
        }
        
        [_viewControllers removeObjectsInRange:NSMakeRange(index+1, [_viewControllers count]-(index+1))];
        
        [self replaceView:[topController view] withView:[viewController view] push:NO animated:isAnimated];
        
        if (updateNavigationBar) {
            [_navigationBar popToNavigationItem:[viewController navigationItem] animated:isAnimated];
        }
        
        [self adjustNavigationBarPositionAnimated:isAnimated];
        
        [topController viewDidDisappear];
        [viewController viewDidAppear];
        
        [self didChangeValueForKey:@"viewControllers"];
        
        for (PXViewController *viewController in viewControllersToPop) {
            if ([[self delegate] respondsToSelector:@selector(navigationController:didPopViewController:animated:)]) {
                [[self delegate] navigationController:self didPopViewController:viewController animated:isAnimated];
            }
        }
        
        if ([[self delegate] respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
            [[self delegate] navigationController:self didShowViewController:viewController animated:isAnimated];
        }
    }
}

- (void)popToViewController:(PXViewController *)viewController animated:(BOOL)isAnimated {
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
    PXViewController *viewController = [newItem representedObject];
    [self popToViewController:viewController animated:YES updateNavigationBar:NO];
}

@end


@implementation PXViewController (PXNavigationController)

static NSString * const PXViewControllerNavigationControllerKey = @"PXViewControllerNavigationControllerKey";
static NSString * const PXViewControllerNavigationItemKey = @"PXViewControllerNavigationItemKey";

- (PXNavigationController *)navigationController {
    PXNavigationController *controller = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerNavigationControllerKey);
    if (controller == nil) {
        PXViewController *parent = self.parentViewController;
        while (parent != nil && controller == nil) {
            controller = parent.navigationController;
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
        [navigationItem bind:NSImageBinding toObject:self withKeyPath:@"image" options:nil];
        [navigationItem setRepresentedObject:self];
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerNavigationItemKey, navigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return navigationItem;
}

@end
