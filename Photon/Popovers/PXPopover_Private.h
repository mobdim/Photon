//
//  PXPopover_Private.h
//  Photon
//
//  Created by Logan Collins on 2/27/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "PXPopover.h"
#import "PXViewController_Private.h"


@interface PXPopover ()

- (PXPopoverBackgroundView *)backgroundView;
- (NSView *)positioningView;

@end


@interface PXPopoverBackgroundView ()

@property (nonatomic, weak) PXPopover *popover;

@end


@interface PXConcretePopoverBackgroundView : PXPopoverBackgroundView

@end


@interface NSViewController (PXPopover)

- (PXPopover *)px_popover;
- (void)px_setPopover:(PXPopover *)popover;

@end
