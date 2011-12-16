//
//  PXViewController.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXViewController.h"
#import "PXViewController_Private.h"

#import "PXNavigationItem.h"
#import "PXTabBarItem.h"


@implementation PXViewController {
    PXViewController *parentViewController;
	
	PXNavigationController *navigationController;
	PXNavigationItem *navigationItem;
	
	PXTabBarController *tabBarController;
	PXTabBarItem *tabBarItem;
}

@dynamic title;
@synthesize image;
@synthesize undoManager;

- (id)initWithView:(NSView *)aView {
	self = [self initWithNibName:nil bundle:nil];
	if (self) {
		[self setView:aView];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		
	}
	return self;
}


#pragma mark -
#pragma mark Overrides

- (void)loadView {
    [super loadView];
    
    // Insert us into the responder chain
    NSView *view = [self view];
    NSResponder *responder = [[self view] nextResponder];
    [view setNextResponder:self];
    [self setNextResponder:responder];
    
    [self viewDidLoad];
}

- (void)viewDidLoad {
    // Overridden by subclasses
}

- (void)viewDidUnload {
    // Overridden by subclasses
}

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

- (PXViewController *)parentViewController {
    return parentViewController;
}

- (void)setParentViewController:(PXViewController *)aViewController {
    if (parentViewController != aViewController) {
        [self willChangeValueForKey:@"parentViewController"];
        [self setNextResponder:nil];
        parentViewController = aViewController;
        [self setNextResponder:parentViewController];
        [self didChangeValueForKey:@"parentViewController"];
    }
}

- (PXNavigationController *)navigationController {
    PXNavigationController *controller = navigationController;
    if (controller == nil) {
        PXViewController *parent = self.parentViewController;
        while (parent != nil && controller == nil) {
            controller = parent.navigationController;
        }
    }
	return controller;
}

- (void)setNavigationController:(PXNavigationController *)controller {
	if (navigationController != controller) {
		[self willChangeValueForKey:@"navigationController"];
		navigationController = controller;
		[self didChangeValueForKey:@"navigationController"];
	}
}

- (PXNavigationItem *)navigationItem {
	if (navigationItem == nil) {
		navigationItem = [[PXNavigationItem alloc] init];
		[navigationItem bind:NSTitleBinding toObject:self withKeyPath:@"title" options:nil];
		[navigationItem bind:NSImageBinding toObject:self withKeyPath:@"image" options:nil];
		[navigationItem setRepresentedObject:self];
	}
	return navigationItem;
}

- (PXTabBarController *)tabBarController {
	PXTabBarController *controller = tabBarController;
    if (controller == nil) {
        PXViewController *parent = self.parentViewController;
        while (parent != nil && controller == nil) {
            controller = parent.tabBarController;
        }
    }
	return controller;
}

- (void)setTabBarController:(PXTabBarController *)controller {
	if (tabBarController != controller) {
		[self willChangeValueForKey:@"tabBarController"];
		tabBarController = controller;
		[self didChangeValueForKey:@"tabBarController"];
	}
}

- (PXTabBarItem *)tabBarItem {
	if (tabBarItem == nil) {
		tabBarItem = [[PXTabBarItem alloc] init];
		[tabBarItem bind:NSTitleBinding toObject:self withKeyPath:@"title" options:nil];
		[tabBarItem bind:NSImageBinding toObject:self withKeyPath:@"image" options:nil];
		[tabBarItem setRepresentedObject:self];
	}
	return tabBarItem;
}

@end
