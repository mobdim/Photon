//
//  PXNavigationItem.m
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXNavigationItem.h"
#import "PXNavigationBackButtonCell.h"


@implementation PXNavigationItem {
    NSTextField *_titleField;
    NSButton *_backButton;
    NSButton *_rightButton;
}

- (void)dealloc {
    [_titleField unbind:NSValueBinding];
    [_backButton unbind:NSTitleBinding];
    [_rightButton unbind:NSTitleBinding];
    [_rightButton unbind:NSImageBinding];
}


#pragma mark -
#pragma mark Accessors

- (NSTextField *)titleField {
    if (_titleField == nil) {
        _titleField = [[NSTextField alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 22.0)];
//        [_titleField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_titleField setBordered:NO];
        [_titleField setBezeled:NO];
        [_titleField setEditable:NO];
        [_titleField setSelectable:NO];
        [_titleField setDrawsBackground:NO];
        [_titleField bind:NSValueBinding toObject:self withKeyPath:@"title" options:nil];
    }
    return _titleField;
}

- (NSButton *)backButton {
    if (_backButton == nil) {
        _backButton = [[NSButton alloc] initWithFrame:NSMakeRect(0.0, 0.0, 32.0, 22.0)];
        PXNavigationBackButtonCell *cell = [[PXNavigationBackButtonCell alloc] initTextCell:@""];
        [_backButton setCell:cell];
//        [_backButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_backButton setBezelStyle:NSTexturedRoundedBezelStyle];
        [_backButton setButtonType:NSMomentaryPushInButton];
        [_backButton setFont:[NSFont controlContentFontOfSize:11.0]];
        [[_backButton cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_backButton bind:NSTitleBinding toObject:self withKeyPath:@"title" options:nil];
    }
    return _backButton;
}

- (NSButton *)rightButton {
    if (_rightButton == nil) {
        _rightButton = [[NSButton alloc] initWithFrame:NSMakeRect(0.0, 0.0, 32.0, 22.0)];
//        [_rightButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_rightButton setBezelStyle:NSTexturedRoundedBezelStyle];
        [_rightButton setButtonType:NSMomentaryPushInButton];
        [_rightButton setImagePosition:NSImageLeft];
        [_rightButton setFont:[NSFont controlContentFontOfSize:11.0]];
        [[_rightButton cell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [_rightButton bind:NSTitleBinding toObject:self withKeyPath:@"rightBarButtonItem.title" options:nil];
        [_rightButton bind:NSImageBinding toObject:self withKeyPath:@"rightBarButtonItem.image" options:nil];
    }
    return _rightButton;
}

@end
