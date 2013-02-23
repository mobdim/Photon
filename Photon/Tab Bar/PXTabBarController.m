//
//  PXTabBarController.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXTabBarController.h"
#import "PXTabBarController_Private.h"
#import "PXTabBar.h"
#import "PXTabBar_Private.h"
#import "PXTabBarItem.h"

#import "PXViewController.h"
#import "PXViewController_Private.h"

#import <objc/runtime.h>


@interface NSViewController (PXTabBarControllerPrivate)

- (void)setTabBarController:(PXTabBarController *)tabBarController;

@end


@implementation PXTabBarController {
    NSMutableArray *_viewControllers;
    PXTabBar *_tabBar;
    NSView *_containerView;
    NSView *_disappearingView;
    NSAnimation *_currentAnimation;
    NSUInteger _selectedIndex;
    NSViewController *_selectedViewController;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"selectedViewController"]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"selectedIndex", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    return keyPaths;
}

- (id)init {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0)];
        [self setView:view];
        
        _viewControllers = [NSMutableArray array];
        _selectedIndex = NSNotFound;
        
        [[self view] setFrameSize:NSMakeSize(280.0, 360.0)];
        [[self view] setWantsLayer:YES];
        
        NSRect bounds = [[self view] bounds];
        _tabBar = [[PXTabBar alloc] initWithFrame:NSMakeRect(0.0, NSMaxY(bounds) - 32.0, NSWidth(bounds), 32.0)];
        _tabBar.autoresizingMask = (NSViewWidthSizable|NSViewMinYMargin);
        _tabBar.delegate = self;
        [[self view] addSubview:_tabBar];
        
        _containerView = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, NSWidth(bounds), NSHeight(bounds) - 32.0)];
        _containerView.autoresizingMask = (NSViewWidthSizable|NSViewHeightSizable);
        [[self view] addSubview:_containerView];
    }
    return self;
}

- (PXTabBar *)tabBar {
    return _tabBar;
}


#pragma mark -
#pragma mark View Controllers

- (NSViewController *)selectedViewController {
    return _selectedViewController;
}

- (void)setSelectedViewController:(NSViewController *)viewController {
    [self setSelectedIndex:[_viewControllers indexOfObjectIdenticalTo:viewController]];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedIndex {
    return [NSSet setWithObjects:@"selectedViewController", nil];
}

- (NSUInteger)selectedIndex {
    return _selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)index {
    [self selectViewControllerAtIndex:index];
}

- (NSArray *)viewControllers {
    return [_viewControllers copy];
}

- (void)setViewControllers:(NSArray *)array {
    if (![_viewControllers isEqualToArray:array]) {
        while ([_viewControllers count] > 0) {
            [self removeViewControllerAtIndex:0];
        }
        
        for (NSViewController *viewController in array) {
            [self addViewController:viewController];
        }
    }
}

- (void)addViewController:(NSViewController *)viewController {
    [self insertViewController:viewController atIndex:[_viewControllers count]];
}

- (void)insertViewController:(NSViewController *)viewController atIndex:(NSUInteger)index {
    if (![_viewControllers containsObject:viewController]) {
        // Start KVO notification
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([_viewControllers count], 1)];
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"viewControllers"];
        
        // Add item
        [viewController setTabBarController:self];
        [viewController setParentViewController:self];
        [_viewControllers insertObject:viewController atIndex:index];
        
        // Add item to tab bar
        PXTabBarItem *item = [viewController tabBarItem];
        [[self tabBar] insertItem:item atIndex:index];
        
        if ([_viewControllers count] == 1) {
            [self selectViewControllerAtIndex:index];
        }
        
        // Finish KVO notification
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"viewControllers"];
    }
}

- (void)removeViewControllerAtIndex:(NSUInteger)index {
    if (index != NSNotFound) {
        NSViewController *viewController = [_viewControllers objectAtIndex:index];
        
        // Start KVO notification
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, 1)];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"viewControllers"];
        
        NSViewController *nextController = nil;
        NSUInteger nextIndex = NSNotFound;
        if (index < [_viewControllers count]-1) {
            nextIndex = [_viewControllers count]-(index+1);
            nextController = [_viewControllers objectAtIndex:nextIndex];
        }
        else if (index > 0) {
            nextIndex = index-1;
            nextController = [_viewControllers objectAtIndex:nextIndex];
        }
        
        [viewController viewWillDisappear];
        [nextController viewWillAppear];
        
        NSView *aView = [nextController view];
        if (aView) {
            [aView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
            [aView setFrame:[_containerView bounds]];
            [_containerView setSubviews:[NSArray arrayWithObject:aView]];
        }
        else {
            [_containerView setSubviews:[NSArray array]];
        }
        
        [self setSelectedIndex:nextIndex];
        
        // Remove item
        [_viewControllers removeObjectAtIndex:index];
        [viewController setTabBarController:nil];
        [viewController setParentViewController:nil];
        [[self tabBar] removeItemAtIndex:index];
        
        [viewController viewDidDisappear];
        [nextController viewDidAppear];
        
        // Finish KVO notification
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"viewControllers"];
    }
}

- (void)removeViewController:(NSViewController *)viewController {
    NSUInteger index = [_viewControllers indexOfObjectIdenticalTo:viewController];
    [self removeViewControllerAtIndex:index];
}

- (NSViewController *)viewControllerAtIndex:(NSUInteger)index {
    return [_viewControllers objectAtIndex:index];
}

- (NSUInteger)indexOfViewController:(NSViewController *)viewController {
    return [_viewControllers indexOfObjectIdenticalTo:viewController];
}

- (void)selectViewController:(NSViewController *)viewController {
    NSUInteger index = [_viewControllers indexOfObjectIdenticalTo:viewController];
    [self selectViewControllerAtIndex:index];
}

- (void)selectViewControllerAtIndex:(NSUInteger)index {
    if (index == self.selectedIndex) {
        return;
    }
    
    if (index != NSNotFound) {
        NSViewController *oldController = [self selectedViewController];
        NSViewController *viewController = [_viewControllers objectAtIndex:index];
        
        [self willChangeValueForKey:@"selectedViewController"];
        
        if ([[self delegate] respondsToSelector:@selector(tabBarController:willSelectViewController:)]) {
            [[self delegate] tabBarController:self willSelectViewController:viewController];
        }
        
        [oldController viewWillDisappear];
        [viewController viewWillAppear];
        
        if (oldController == nil || viewController == nil || [[self view] window] == nil) {
            NSView *aView = [viewController view];
            if (aView) {
                [aView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
                [aView setFrame:[_containerView bounds]];
                [_containerView setSubviews:[NSArray arrayWithObject:aView]];
            }
            else {
                [_containerView setSubviews:[NSArray array]];
            }
        }
        else {
            BOOL shouldPush = NO;
            NSUInteger oldIndex = [_viewControllers indexOfObjectIdenticalTo:oldController];
            if (oldIndex < index) {
                shouldPush = YES;
            }
            [self replaceView:[oldController view] withView:[viewController view] push:shouldPush animated:[self animatesViewTransition]];
        }
        
        [[self tabBar] setSelectedItem:[viewController tabBarItem]];
        _selectedIndex = index;
        _selectedViewController = viewController;
        
        [oldController viewDidDisappear];
        [viewController viewDidAppear];
        
        if ([[self delegate] respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
            [[self delegate] tabBarController:self didSelectViewController:viewController];
        }
        
        [self didChangeValueForKey:@"selectedViewController"];
    }
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
        [newView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
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
        [newView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
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


#pragma mark -
#pragma mark Tab Bar delegate

- (BOOL)tabBar:(PXTabBar *)aTabBarController shouldSelectItem:(PXTabBarItem *)item {
    if ([[self delegate] respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        return [[self delegate] tabBarController:self shouldSelectViewController:[item representedObject]];
    }
    return YES;
}

- (void)tabBar:(PXTabBar *)aTabBarController willSelectItem:(PXTabBarItem *)item {
    
}

- (void)tabBar:(PXTabBar *)aTabBarController didSelectItem:(PXTabBarItem *)item {
    NSViewController *viewController = [item representedObject];
    NSUInteger index = [_viewControllers indexOfObjectIdenticalTo:viewController];
    [self selectViewControllerAtIndex:index];
}

@end


@implementation NSViewController (PXTabBarController)

static NSString * const PXViewControllerTabBarControllerKey = @"PXViewControllerTabBarController";
static NSString * const PXViewControllerTabBarItemKey = @"PXViewControllerTabBarItem";

- (PXTabBarController *)tabBarController {
    PXTabBarController *controller = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerTabBarControllerKey);
    if (controller == nil) {
        NSViewController *parent = self.parentViewController;
        while (parent != nil && controller == nil) {
            controller = parent.tabBarController;
            parent = parent.parentViewController;
        }
    }
    return controller;
}

- (void)setTabBarController:(PXTabBarController *)tabBarController {
    PXTabBarController *currentTabBarController = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerTabBarControllerKey);
    if (currentTabBarController != tabBarController) {
        [self willChangeValueForKey:@"navigationController"];
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerTabBarControllerKey, tabBarController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"navigationController"];
    }
}

- (PXTabBarItem *)tabBarItem {
    PXTabBarItem *tabBarItem = objc_getAssociatedObject(self, (__bridge void *)PXViewControllerTabBarItemKey);
    if (tabBarItem == nil) {
        tabBarItem = [[PXTabBarItem alloc] init];
        [tabBarItem bind:NSTitleBinding toObject:self withKeyPath:@"title" options:nil];
        //[navigationItem bind:NSImageBinding toObject:self withKeyPath:@"image" options:nil];
        [tabBarItem setRepresentedObject:self];
        objc_setAssociatedObject(self, (__bridge void *)PXViewControllerTabBarItemKey, tabBarItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tabBarItem;
}

@end
