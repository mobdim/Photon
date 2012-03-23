//
//  PXTabBarController.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXTabBarController.h"
#import "PXTabBarController_Private.h"
#import "PXTabBar.h"
#import "PXTabBar_Private.h"
#import "PXTabBarItem.h"

#import "PXViewController.h"
#import "PXViewController_Private.h"


NSString * const PXTabBarControllerWillAddViewControllerNotification = @"PXTabBarControllerWillAddViewController";
NSString * const PXTabBarControllerDidAddViewControllerNotification = @"PXTabBarControllerDidAddViewController";

NSString * const PXTabBarControllerWillRemoveViewControllerNotification = @"PXTabBarControllerWillRemoveViewController";
NSString * const PXTabBarControllerDidRemoveViewControllerNotification = @"PXTabBarControllerDidRemoveViewController";

NSString * const PXTabBarControllerWillSelectViewControllerNotification = @"PXTabBarControllerWillSelectViewController";
NSString * const PXTabBarControllerDidSelectViewControllerNotification = @"PXTabBarControllerDidSelectViewController";


@implementation PXTabBarController {
	NSMutableArray *viewControllers;
	PXTabBar *tabBar;
    NSView *disappearingView;
    NSAnimation *currentAnimation;
    NSUInteger selectedIndex;
}

@synthesize delegate;
@synthesize containerView;
@synthesize animates;

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"selectedViewController"]) {
		NSSet *affectingKeys = [NSSet setWithObjects:@"selectedIndex", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKeys];
	}
	
	return keyPaths;
}

- (id)init {
	self = [self initWithNibName:@"TabBarView" bundle:[NSBundle bundleForClass:[PXTabBarController class]]];
	if (self) {
		
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
	[tabBar setDelegate:self];
	
	// Set up views
	[tabBar setFrameOrigin:NSMakePoint(0.0, [[self view] bounds].size.height - [tabBar bounds].size.height)];
	[containerView setFrame:NSMakeRect(0.0, 0.0, [[self view] bounds].size.width, [[self view] bounds].size.height - [tabBar bounds].size.height)];
}

- (PXTabBar *)tabBar {
	if (tabBar == nil) {
		[self view];
	}
	return tabBar;
}

- (void)setTabBar:(PXTabBar *)newTabBar {
	if (tabBar != newTabBar) {
		[self willChangeValueForKey:@"tabBar"];
		tabBar = newTabBar;
		[self didChangeValueForKey:@"tabBar"];
	}
}


#pragma mark -
#pragma mark View Controllers

- (PXViewController *)selectedViewController {
    PXTabBarItem *item = [tabBar selectedItem];
	return [item representedObject];
}

- (void)setSelectedViewController:(PXViewController *)selectedViewController {
    [viewControllers objectAtIndex:selectedIndex];
}

+ (NSSet *)keyPathsForValuesAffectingSelectedIndex {
    return [NSSet setWithObjects:@"selectedViewController", nil];
}

- (NSUInteger)selectedIndex {
    return selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)index {
	[self selectViewControllerAtIndex:index];
}

- (NSArray *)viewControllers {
	return [viewControllers copy];
}

- (void)setViewControllers:(NSArray *)array {
	if (![viewControllers isEqualToArray:array]) {
		while ([viewControllers count] > 0) {
            [self removeViewControllerAtIndex:0];
        }
        
        for (PXViewController *viewController in array) {
            [self addViewController:viewController];
        }
	}
}

- (void)addViewController:(PXViewController *)viewController {
	[self insertViewController:viewController atIndex:[viewControllers count]];
}

- (void)insertViewController:(PXViewController *)viewController atIndex:(NSUInteger)index {
	if (![viewControllers containsObject:viewController]) {
		// Post notification
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:viewController, @"viewController", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXTabBarControllerWillAddViewControllerNotification object:self userInfo:userInfo];
		
		// Start KVO notification
		NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange([viewControllers count], 1)];
		[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"viewControllers"];
		
		// Add item
		[viewController setTabBarController:self];
        [viewController setParentViewController:self];
		[viewControllers insertObject:viewController atIndex:index];
		
		// Add item to tab bar
		PXTabBarItem *item = [viewController tabBarItem];
		[[self tabBar] insertItem:item atIndex:index];
		
		if ([viewControllers count] == 1) {
			[self selectViewControllerAtIndex:index];
		}
		
		// Finish KVO notification
		[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"viewControllers"];
		
		// Post notification
		[[NSNotificationCenter defaultCenter] postNotificationName:PXTabBarControllerDidAddViewControllerNotification object:self userInfo:userInfo];
	}
}

- (void)removeViewControllerAtIndex:(NSUInteger)index {
	if (index != NSNotFound) {
		PXViewController *viewController = [viewControllers objectAtIndex:index];
		
		// Post notification
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:viewController, @"viewController", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXTabBarControllerWillRemoveViewControllerNotification object:self userInfo:userInfo];
		
		// Start KVO notification
		NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, 1)];
		[self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"viewControllers"];
		
		PXViewController *nextController = nil;
		NSUInteger nextIndex = NSNotFound;
		if (index < [viewControllers count]-1) {
			nextIndex = [viewControllers count]-(index+1);
			nextController = [viewControllers objectAtIndex:nextIndex];
		}
		else if (index > 0) {
			nextIndex = index-1;
			nextController = [viewControllers objectAtIndex:nextIndex];
		}
		
		[viewController viewWillDisappear];
		[nextController viewWillAppear];
		
		NSView *aView = [nextController view];
		if (aView) {
            [aView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
			[aView setFrame:[containerView bounds]];
			[containerView setSubviews:[NSArray arrayWithObject:aView]];
		}
		else {
			[containerView setSubviews:[NSArray array]];
		}
		
		[self setSelectedIndex:nextIndex];
		
		// Remove item
		[viewControllers removeObjectAtIndex:index];
		[viewController setTabBarController:nil];
        [viewController setParentViewController:nil];
        [[self tabBar] removeItemAtIndex:index];
		
		[viewController viewDidDisappear];
		[nextController viewDidAppear];
		
		// Finish KVO notification
		[self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"viewControllers"];
		
		// Post notification
		[[NSNotificationCenter defaultCenter] postNotificationName:PXTabBarControllerDidRemoveViewControllerNotification object:self userInfo:userInfo];
	}
}

- (void)removeViewController:(PXViewController *)viewController {
	NSUInteger index = [viewControllers indexOfObjectIdenticalTo:viewController];
	[self removeViewControllerAtIndex:index];
}

- (PXViewController *)viewControllerAtIndex:(NSUInteger)index {
	return [viewControllers objectAtIndex:index];
}

- (NSUInteger)indexOfViewController:(PXViewController *)viewController {
    return [viewControllers indexOfObjectIdenticalTo:viewController];
}

- (void)selectViewController:(PXViewController *)viewController {
	NSUInteger index = [viewControllers indexOfObjectIdenticalTo:viewController];
	[self selectViewControllerAtIndex:index];
}

- (void)selectViewControllerAtIndex:(NSUInteger)index {
    if (index == self.selectedIndex) {
        return;
    }
    
	if (index != NSNotFound) {
		PXViewController *oldController = [self selectedViewController];
		PXViewController *viewController = [viewControllers objectAtIndex:index];
        
        [self willChangeValueForKey:@"selectedViewController"];
		
		if ([[self delegate] respondsToSelector:@selector(tabBarController:willSelectViewController:)]) {
			[[self delegate] tabBarController:self willSelectViewController:viewController];
		}
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:viewController, @"viewController", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:PXTabBarControllerWillSelectViewControllerNotification object:self userInfo:userInfo];
		
		[oldController viewWillDisappear];
		[viewController viewWillAppear];
		
        if (oldController != nil) {
            BOOL shouldPush = NO;
            NSUInteger oldIndex = [viewControllers indexOfObjectIdenticalTo:oldController];
            if (oldIndex < index) {
                shouldPush = YES;
            }
            [self replaceView:[oldController view] withView:[viewController view] push:shouldPush animated:[self animates]];
        }
        else {
            NSView *aView = [viewController view];
            if (aView) {
                [aView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
                [aView setFrame:[containerView bounds]];
                [containerView setSubviews:[NSArray arrayWithObject:aView]];
            }
            else {
                [containerView setSubviews:[NSArray array]];
            }
        }
		
		[[self tabBar] setSelectedItem:[viewController tabBarItem]];
        selectedIndex = index;
		
		[oldController viewDidDisappear];
		[viewController viewDidAppear];
		
		if ([[self delegate] respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
			[[self delegate] tabBarController:self didSelectViewController:viewController];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PXTabBarControllerDidSelectViewControllerNotification object:self userInfo:userInfo];
        
        [self didChangeValueForKey:@"selectedViewController"];
	}
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
        [newView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
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
        [newView setAutoresizingMask:(NSViewWidthSizable|NSViewHeightSizable)];
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
	PXViewController *viewController = [item representedObject];
	NSUInteger index = [viewControllers indexOfObjectIdenticalTo:viewController];
	[self selectViewControllerAtIndex:index];
}

@end
