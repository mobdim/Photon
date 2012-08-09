//
//  PXNavigationController.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationController.h"
#import "PXNavigationBar.h"
#import "PXNavigationItem.h"

#import "PXViewController.h"
#import "PXViewController_Private.h"

#import "PXNavigationPathComponentCell.h"


@interface PXNavigationController ()

- (void)adjustNavigationBarPosition;
- (void)replaceView:(NSView *)oldView withView:(NSView *)newView push:(BOOL)shouldPush animated:(BOOL)isAnimated;

@end


@implementation PXNavigationController {
    NSMutableArray *viewControllers;
    
    IBOutlet NSView *containerView;
    PXNavigationBar *navigationBar;
    
    NSAnimation *currentAnimation;
    NSView *disappearingView;
    
    BOOL alwaysShowsNavigationBar;
}

@synthesize delegate;

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"topViewController"]) {
        NSSet *affectingKeys = [NSSet setWithObjects:@"viewControllers", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
    }
    
    return keyPaths;
}

- (id)init {
    self = [self initWithNibName:@"NavigationView" bundle:[NSBundle bundleForClass:[PXNavigationController class]]];
    if (self) {
        
    }
    return self;
}

- (id)initWithRootViewController:(PXViewController *)viewController {
    self = [self initWithNibName:@"NavigationView" bundle:[NSBundle bundleForClass:[PXNavigationController class]]];
    if (self) {
        viewController.navigationController = self;
        [viewControllers addObject:viewController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        viewControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    
    // Set up navigation bar
    [navigationBar setDelegate:self];
    
    for (PXViewController *viewController in self.viewControllers) {
        [navigationBar pushNavigationItem:[viewController navigationItem]];
    }
    
    
    // Set up views and animations
    [self adjustNavigationBarPosition];
    
    
    // Load root view controller
    if ([viewControllers count] > 0) {
        PXViewController *rootViewController = [viewControllers objectAtIndex:0];
        NSView *newView = [rootViewController view];
        [newView setFrame:[containerView bounds]];
        [containerView setSubviews:[NSArray arrayWithObject:newView]];
    }
}

- (void)adjustNavigationBarPosition {
    id navigationBarProxy = ([[[self view] window] isVisible] ? [navigationBar animator] : navigationBar);
    id containerViewProxy = ([[[self view] window] isVisible] ? [containerView animator] : containerView);
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.15];
    
    if ([viewControllers count] <= 1 && alwaysShowsNavigationBar == NO) {
        [navigationBarProxy setFrameOrigin:NSMakePoint(0.0, NSMaxY([[self view] bounds]))];
        [containerViewProxy setFrame:[[self view] bounds]];
    }
    else {
        NSPoint newNavBarOrigin = NSMakePoint(0.0, NSMaxY([[self view] bounds]) - [navigationBar frame].size.height);
        [navigationBarProxy setFrameOrigin:newNavBarOrigin];
        
        NSRect newFrame = [[self view] bounds];
        newFrame.size.height -= [navigationBar frame].size.height;
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
    if (navigationBar == nil) {
        [self view];
    }
    return navigationBar;
}

- (void)setNavigationBar:(PXNavigationBar *)newNavigationBar {
    if (navigationBar != newNavigationBar) {
        [self willChangeValueForKey:@"navigationBar"];
        navigationBar = newNavigationBar;
        [self didChangeValueForKey:@"navigationBar"];
    }
}

- (BOOL)alwaysShowsNavigationBar {
    return alwaysShowsNavigationBar;
}

- (void)setAlwaysShowsNavigationBar:(BOOL)flag {
    if (alwaysShowsNavigationBar != flag) {
        [self willChangeValueForKey:@"alwaysShowsNavigationBar"];
        
        alwaysShowsNavigationBar = flag;
        
        [self adjustNavigationBarPosition];
        
        [self didChangeValueForKey:@"alwaysShowsNavigationBar"];
    }
}


#pragma mark -
#pragma mark View Controllers

- (NSArray *)viewControllers {
    return [viewControllers copy];
}

- (void)setViewControllers:(NSArray *)newArray {
    [self setViewControllers:newArray animated:NO];
}

- (void)setViewControllers:(NSArray *)array animated:(BOOL)isAnimated {
    if (![viewControllers isEqualToArray:array]) {
        [self willChangeValueForKey:@"viewControllers"];
        
        PXViewController *currentTopController = [viewControllers lastObject];
        PXViewController *newTopController = [array lastObject];
        
        [currentTopController viewWillDisappear];
        [newTopController viewWillAppear];
        
        [self adjustNavigationBarPosition];
        
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
            [[newTopController view] setFrame:[containerView bounds]];
            if (isAnimated) {
                [[containerView animator] setSubviews:[NSArray arrayWithObject:[newTopController view]]];
            }
            else {
                [containerView setSubviews:[NSArray arrayWithObject:[newTopController view]]];
            }
        }
        
        for (PXViewController *controller in viewControllers) {
            [controller setNavigationController:nil];
            [controller setParentViewController:nil];
        }
        
        [viewControllers removeAllObjects];
        [viewControllers setArray:array];
        
        for (PXViewController *controller in viewControllers) {
            [controller setNavigationController:self];
            [controller setParentViewController:self];
        }
        
        NSMutableArray *navigationBarItems = [NSMutableArray array];
        for (PXViewController *viewController in array) {
            [navigationBarItems addObject:[viewController navigationItem]];
        }
        [navigationBar setItems:navigationBarItems];
        
        [currentTopController viewDidDisappear];
        [newTopController viewDidAppear];
        
        [self didChangeValueForKey:@"viewControllers"];
    }
}

- (PXViewController *)topViewController {
    return [viewControllers lastObject];
}

- (void)replaceView:(NSView *)oldView withView:(NSView *)newView push:(BOOL)shouldPush animated:(BOOL)isAnimated {
    if ([[[oldView window] firstResponder] isKindOfClass:[NSView class]] && [(NSView *)[[oldView window] firstResponder] isDescendantOf:oldView]) {
        [[oldView window] makeFirstResponder:nil];
    }
    
    if (isAnimated) {
        disappearingView = oldView;
        
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
        [containerView addSubview:newView];
        
        
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
        
        currentAnimation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
        [currentAnimation setDelegate:self];
        [currentAnimation setAnimationBlockingMode:NSAnimationBlocking];
        [currentAnimation setDuration:0.25];
        [currentAnimation setAnimationCurve:NSAnimationEaseInOut];
        [currentAnimation startAnimation];
    }
    else {
        [newView setFrame:[oldView frame]];
        [oldView removeFromSuperview];
        [containerView addSubview:newView];
    }
}

- (void)animationDidStop:(NSAnimation *)animation {
    [disappearingView removeFromSuperview];
    disappearingView = nil;
    currentAnimation = nil;
}

- (void)animationDidEnd:(NSAnimation*)animation {
    [disappearingView removeFromSuperview];
    disappearingView = nil;
    currentAnimation = nil;
}

- (void)pushViewController:(PXViewController *)viewController animated:(BOOL)isAnimated {
    if ([[self delegate] respondsToSelector:@selector(navigationController:willPushViewController:animated:)]) {
        [[self delegate] navigationController:self willPushViewController:viewController animated:isAnimated];
    }
    
    [self willChangeValueForKey:@"viewControllers"];
    
    PXViewController *currentViewController = [self topViewController];
    
    [currentViewController viewWillDisappear];
    [viewController viewWillAppear];
    
    [viewControllers addObject:viewController];
    
    [viewController setNavigationController:self];
    [viewController setParentViewController:self];
    
    [navigationBar pushNavigationItem:[viewController navigationItem]];
    
    [self adjustNavigationBarPosition];
    
    NSView *oldView = [[containerView subviews] lastObject];
    [self replaceView:oldView withView:[viewController view] push:YES animated:isAnimated];
    
    [currentViewController viewDidDisappear];
    [viewController viewDidAppear];
    
    [self didChangeValueForKey:@"viewControllers"];
    
    if ([[self delegate] respondsToSelector:@selector(navigationController:didPushViewController:animated:)]) {
        [[self delegate] navigationController:self didPushViewController:viewController animated:isAnimated];
    }
}

- (void)popViewControllerAnimated:(BOOL)isAnimated {
    if ([viewControllers count] > 1) {
        PXViewController *nextController = [viewControllers objectAtIndex:[viewControllers count]-2];
        
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
        
        [viewControllers removeObjectAtIndex:[viewControllers count]-1];
        
        [self adjustNavigationBarPosition];
        
        [self replaceView:[topController view] withView:[nextController view] push:NO animated:isAnimated];
        
        [navigationBar popNavigationItem];
        
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
    PXViewController *rootController = (([viewControllers count] > 0) ? [viewControllers objectAtIndex:0] : nil);
    PXViewController *topController = [viewControllers lastObject];
    
    if (rootController != nil && rootController != topController) {
        NSArray *viewControllersToPop = [viewControllers subarrayWithRange:NSMakeRange(1, [viewControllers count]-1)];
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
        
        [viewControllers removeObjectsInRange:NSMakeRange(1, [viewControllers count]-1)];
        
        [self replaceView:[topController view] withView:[rootController view] push:NO animated:isAnimated];
        
        [navigationBar popToRootNavigationItem];
        
        [self adjustNavigationBarPosition];
        
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
    PXViewController *topController = [viewControllers lastObject];
    
    NSInteger index = [viewControllers indexOfObjectIdenticalTo:viewController];
    if (index != NSNotFound && viewController != nil && viewController != topController) {
        NSArray *viewControllersToPop = [viewControllers subarrayWithRange:NSMakeRange(index+1, [viewControllers count]-(index+1))];
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
        
        [viewControllers removeObjectsInRange:NSMakeRange(index+1, [viewControllers count]-(index+1))];
        
        [self replaceView:[topController view] withView:[viewController view] push:NO animated:isAnimated];
        
        if (updateNavigationBar) {
            [navigationBar popToNavigationItem:[viewController navigationItem]];
        }
        
        [self adjustNavigationBarPosition];
        
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

- (BOOL)navigationBar:(PXNavigationBar *)bar shouldPopToItem:(PXNavigationItem *)item {
    return YES;
}

- (void)navigationBar:(PXNavigationBar *)bar didPopToItem:(PXNavigationItem *)item {
    PXViewController *viewController = [item representedObject];
    [self popToViewController:viewController animated:YES updateNavigationBar:NO];
}

@end
