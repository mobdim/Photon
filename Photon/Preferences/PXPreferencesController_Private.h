//
//  PXPreferencesController_Private.h
//  Photon
//
//  Created by Logan Collins on 12/16/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Photon/PXPreferencesController.h>


@interface PXPreferencesController () <NSWindowDelegate, NSToolbarDelegate>

- (void)toggleActivePreferenceView:(NSToolbarItem *)item;
- (void)showPreferencePaneWithIdentifier:(NSString *)identifier animate:(BOOL)shouldAnimate;
- (void)confirmedShowPreferencePaneWithIdentifier:(NSString *)identifier animate:(BOOL)shouldAnimate;
- (NSRect)frameForView:(NSView *)view;

@end
