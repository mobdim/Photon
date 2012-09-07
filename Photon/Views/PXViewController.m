//
//  PXViewController.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXViewController.h"
#import "PXViewController_Private.h"

#import "PXNavigationItem.h"
#import "PXTabBarItem.h"


@implementation PXViewController {
    BOOL _viewLoaded;
    PXViewController *_parentViewController;
    
    PXTabBarController *_tabBarController;
    PXTabBarItem *_tabBarItem;
}

@dynamic title;

- (id)init {
    return [self initWithView:[[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0)]];
}

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

- (void)dealloc {
    [self viewDidUnload];
}


#pragma mark -
#pragma mark Overrides

- (NSView *)view {
    NSView *view = [super view];
    if (!_viewLoaded) {
        _viewLoaded = YES;
        [self viewDidLoad];
    }
    return view;
}

- (void)loadView {
    [super loadView];
    
    // Insert us into the responder chain
    NSView *view = [self view];
    NSResponder *responder = [[self view] nextResponder];
    [view setNextResponder:self];
    [self setNextResponder:responder];
    
    _viewLoaded = YES;
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
    return _parentViewController;
}

- (void)setParentViewController:(PXViewController *)aViewController {
    if (_parentViewController != aViewController) {
        [self willChangeValueForKey:@"parentViewController"];
        [self setNextResponder:nil];
        _parentViewController = aViewController;
        [self setNextResponder:_parentViewController];
        [self didChangeValueForKey:@"parentViewController"];
    }
}

- (PXTabBarController *)tabBarController {
    PXTabBarController *controller = _tabBarController;
    if (controller == nil) {
        PXViewController *parent = self.parentViewController;
        while (parent != nil && controller == nil) {
            controller = parent.tabBarController;
        }
    }
    return controller;
}

- (void)setTabBarController:(PXTabBarController *)controller {
    if (_tabBarController != controller) {
        [self willChangeValueForKey:@"tabBarController"];
        _tabBarController = controller;
        [self didChangeValueForKey:@"tabBarController"];
    }
}

- (PXTabBarItem *)tabBarItem {
    if (_tabBarItem == nil) {
        _tabBarItem = [[PXTabBarItem alloc] init];
        [_tabBarItem bind:NSTitleBinding toObject:self withKeyPath:@"title" options:nil];
        [_tabBarItem bind:NSImageBinding toObject:self withKeyPath:@"image" options:nil];
        [_tabBarItem setRepresentedObject:self];
    }
    return _tabBarItem;
}

@end
