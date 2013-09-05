//
//  PXView.m
//  Photon
//
//  Created by Logan Collins on 9/2/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "PXView.h"


@implementation PXView {
    NSColor *_backgroundColor;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
    if (self.layer == nil && _backgroundColor != nil) {
        [_backgroundColor set];
        NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    }
}


#pragma mark -
#pragma mark Accessors

- (NSColor *)backgroundColor {
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if (self.layer != nil) {
        self.layer.backgroundColor = _backgroundColor.CGColor;
    }
}

@end
