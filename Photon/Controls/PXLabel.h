//
//  PXLabel.h
//  Photon
//
//  Created by Logan Collins on 3/5/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PXLabel : NSView

@property (nonatomic, copy) NSColor *backgroundColor;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSFont *font;
@property (nonatomic, strong) NSColor *textColor;
@property (nonatomic, strong) NSColor *shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) NSLineBreakMode lineBreakMode;

@property (nonatomic, copy) NSAttributedString *attributedText;

@property (nonatomic, strong) NSColor *highlightedTextColor;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;

- (void)drawTextInRect:(CGRect)rect;

@end
