//
//  PXLabel.m
//  Photon
//
//  Created by Logan Collins on 3/5/13.
//  Copyright (c) 2013 Sunflower Softworks. All rights reserved.
//

#import "PXLabel.h"


static NSString * const PXLabelRedrawPropertyObservationContext = @"PXLabelPropertyObservationContext";
static NSString * const PXLabelLayoutPropertyObservationContext = @"PXLabelLayoutPropertyObservationContext";


@implementation PXLabel {
    NSMutableAttributedString *_attributedText;
    BOOL _ownsAttributedText;
    NSFont *_font;
    NSColor *_textColor;
    NSShadow *_shadow;
    BOOL _highlighted;
    NSColor *_highlightedTextColor;
    NSParagraphStyle *_paragraphStyle;
}

static NSSet *__redrawKeyPaths = nil;
static NSSet *__layoutKeyPaths = nil;

+ (void)initialize {
    if (self == [PXLabel class]) {
        __redrawKeyPaths = [NSSet setWithObjects:@"backgroundColor", @"text", @"font", @"textColor", @"textAlignment", @"lineBreakMode", @"attributedText", @"highlightedTextColor", @"highlighted", nil];
        __layoutKeyPaths = [NSSet setWithObjects:@"text", @"font", @"textAlignment", @"lineBreakMode", @"attributedText", nil];
    }
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        for (NSString *keyPath in __redrawKeyPaths) {
            [self addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionNew) context:(__bridge void *)PXLabelRedrawPropertyObservationContext];
        }
        for (NSString *keyPath in __layoutKeyPaths) {
            [self addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionNew) context:(__bridge void *)PXLabelLayoutPropertyObservationContext];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        for (NSString *keyPath in __redrawKeyPaths) {
            [self addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionNew) context:(__bridge void *)PXLabelRedrawPropertyObservationContext];
        }
        for (NSString *keyPath in __layoutKeyPaths) {
            [self addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionNew) context:(__bridge void *)PXLabelLayoutPropertyObservationContext];
        }
    }
    return self;
}

- (void)dealloc {
    for (NSString *keyPath in __redrawKeyPaths) {
        [self removeObserver:self forKeyPath:keyPath context:(__bridge void *)PXLabelRedrawPropertyObservationContext];
    }
    for (NSString *keyPath in __layoutKeyPaths) {
        [self removeObserver:self forKeyPath:keyPath context:(__bridge void *)PXLabelLayoutPropertyObservationContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == (__bridge void *)PXLabelRedrawPropertyObservationContext) {
        [self setNeedsDisplay:YES];
    }
    else if (context == (__bridge void *)PXLabelLayoutPropertyObservationContext) {
        [self invalidateIntrinsicContentSize];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark -
#pragma mark Accessors

- (NSString *)text {
    return [_attributedText string];
}

- (void)setText:(NSString *)text {
    if (text != nil) {
        _attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        
        if (_font != nil) {
            [_attributedText addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, [_attributedText length])];
        }
        else {
            [_attributedText addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:12.0] range:NSMakeRange(0, [_attributedText length])];
        }
        
        if (_textColor != nil) {
            [_attributedText addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, [_attributedText length])];
        }
        else {
            [_attributedText addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0, [_attributedText length])];
        }
        
        if (_paragraphStyle != nil) {
            [_attributedText addAttribute:NSParagraphStyleAttributeName value:_paragraphStyle range:NSMakeRange(0, [_attributedText length])];
        }
        else {
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            [_attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_attributedText length])];
        }
    }
    else {
        _attributedText = nil;
    }
    
    _ownsAttributedText = YES;
}

- (NSFont *)font {
    return _font;
}

- (void)setFont:(NSFont *)font {
    NSParameterAssert(font != nil);
    
    _font = font;
    [_attributedText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [_attributedText length])];
}

- (NSColor *)textColor {
    return _textColor;
}

- (void)setTextColor:(NSColor *)textColor {
    NSParameterAssert(textColor != nil);
    
    _textColor = textColor;
    [_attributedText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [_attributedText length])];
}

- (NSTextAlignment)textAlignment {
    return (_paragraphStyle != nil ? _paragraphStyle.alignment : NSLeftTextAlignment);
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    if (_paragraphStyle != nil) {
        NSMutableParagraphStyle *paragraphStyle = [_paragraphStyle mutableCopy];
        paragraphStyle.alignment = textAlignment;
        _paragraphStyle = paragraphStyle;
    }
    else {
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.alignment = textAlignment;
        _paragraphStyle = paragraphStyle;
    }
    [_attributedText addAttribute:NSParagraphStyleAttributeName value:_paragraphStyle range:NSMakeRange(0, [_attributedText length])];
}

- (NSLineBreakMode)lineBreakMode {
    return (_paragraphStyle != nil ? _paragraphStyle.lineBreakMode : NSLineBreakByTruncatingTail);
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    if (_paragraphStyle != nil) {
        NSMutableParagraphStyle *paragraphStyle = [_paragraphStyle mutableCopy];
        paragraphStyle.lineBreakMode = lineBreakMode;
        _paragraphStyle = paragraphStyle;
    }
    else {
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = lineBreakMode;
        _paragraphStyle = paragraphStyle;
    }
    [_attributedText addAttribute:NSParagraphStyleAttributeName value:_paragraphStyle range:NSMakeRange(0, [_attributedText length])];
}

- (NSAttributedString *)attributedText {
    return [_attributedText copy];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText != nil) {
        _attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    }
    else {
        _attributedText = nil;
    }
    
    _ownsAttributedText = NO;
    _font = nil;
    _textColor = nil;
    _paragraphStyle = nil;
    _shadow = nil;
}

- (NSColor *)shadowColor {
    return _shadow.shadowColor;
}

- (void)setShadowColor:(NSColor *)shadowColor {
    if (shadowColor != nil) {
        if (_shadow == nil) {
            _shadow = [[NSShadow alloc] init];
            _shadow.shadowBlurRadius = 0.0;
            _shadow.shadowOffset = NSMakeSize(0.0, 1.0);
        }
        _shadow.shadowColor = shadowColor;
        [_attributedText addAttribute:NSShadowAttributeName value:_shadow range:NSMakeRange(0, [_attributedText length])];
    }
    else {
        [_attributedText removeAttribute:NSShadowAttributeName range:NSMakeRange(0, [_attributedText length])];
    }
}

- (CGSize)shadowOffset {
    return _shadow.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    if (_shadow == nil) {
        _shadow = [[NSShadow alloc] init];
        _shadow.shadowBlurRadius = 0.0;
        _shadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.5];
    }
    _shadow.shadowOffset = shadowOffset;
    [_attributedText addAttribute:NSShadowAttributeName value:_shadow range:NSMakeRange(0, [_attributedText length])];
}

- (BOOL)isHighlighted {
    return _highlighted;
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    if (_ownsAttributedText) {
        if (highlighted && _highlightedTextColor != nil) {
            [_attributedText addAttribute:NSForegroundColorAttributeName value:_highlightedTextColor range:NSMakeRange(0, [_attributedText length])];
        }
        else {
            NSColor *textColor = _textColor;
            if (textColor == nil) {
                textColor = [NSColor blackColor];
            }
            [_attributedText addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [_attributedText length])];
        }
    }
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    if (self.backgroundColor != nil) {
        [self.backgroundColor set];
        CGContextFillRect(ctx, self.bounds);
    }
    [self drawTextInRect:self.bounds];
}

- (void)drawTextInRect:(CGRect)rect {
    [_attributedText drawInRect:rect];
}

- (BOOL)isOpaque {
    return (self.backgroundColor != nil) && ([self.backgroundColor alphaComponent] == 1.0);
}


#pragma mark -
#pragma mark Metrics

- (NSSize)intrinsicContentSize {
    return [self sizeThatFits:self.frame.size];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGRect boundingRect = [_attributedText boundingRectWithSize:size options:0];
    return boundingRect.size;
}

- (void)sizeToFit {
    [self setFrameSize:[self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)]];
}

- (CGFloat)baselineOffsetFromBottom {
    CGRect boundingRect = [_attributedText boundingRectWithSize:self.frame.size options:0];
    return self.frame.size.height - boundingRect.origin.y;
}


#pragma mark -
#pragma mark Accessibility

- (BOOL)accessibilityIsIgnored {
    return NO;
}

- (NSArray *)accessibilityAttributeNames {
    NSArray *attributeNames = [super accessibilityAttributeNames];
    attributeNames = [attributeNames arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:
                                                                    NSAccessibilityValueAttribute,
                                                                    nil]];
    return attributeNames;
}

- (id)accessibilityAttributeValue:(NSString *)attribute {
    if ([attribute isEqualToString:NSAccessibilityRoleAttribute]) {
        return NSAccessibilityStaticTextRole;
    }
    else if ([attribute isEqualToString:NSAccessibilityValueAttribute]) {
        return self.text;
    }
    return [super accessibilityAttributeValue:attribute];
}

@end
