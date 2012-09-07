//
//  PXNavigationItem_Private.h
//  Photon
//
//  Created by Logan Collins on 9/7/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Photon/PXNavigationItem.h>


@interface PXNavigationItem ()

@property (nonatomic, strong, readonly) NSTextField *titleField;
@property (nonatomic, strong, readonly) NSButton *backButton;
@property (nonatomic, copy) NSButton *rightButton;

@end
