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
    NSAttributedString *_attributedString;
    NSBackgroundStyle _backgroundStyle;
}

static NSSet *__redrawKeyPaths = nil;
static NSSet *__layoutKeyPaths = nil;

+ (void)initialize {
    if (self == [PXLabel class]) {
        __redrawKeyPaths = [NSSet setWithObjects:@"backgroundColor", @"text", @"font", @"textColor", @"textAlignment", @"lineBreakMode", @"highlightedTextColor", @"highlighted", nil];
        __layoutKeyPaths = [NSSet setWithObjects:@"text", @"font", @"textAlignment", @"lineBreakMode", nil];
    }
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [NSFont fontWithName:@"Helvetica" size:11.0];
        self.textColor = [NSColor blackColor];
        self.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textAlignment = NSLeftTextAlignment;
        
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
        _attributedString = nil;
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

- (NSBackgroundStyle)backgroundStyle {
    return _backgroundStyle;
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
    _backgroundStyle = backgroundStyle;
    if (_backgroundStyle == NSBackgroundStyleLight) {
        self.highlighted = NO;
    }
    else {
        self.highlighted = YES;
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

- (NSAttributedString *)attributedString {
    if (_attributedString == nil) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        
        if (self.font != nil) {
            attributes[NSFontAttributeName] = self.font;
        }
        
        if (self.textColor != nil) {
            attributes[NSForegroundColorAttributeName] = self.textColor;
        }
        
        if (self.highlighted && self.highlightedTextColor != nil) {
            attributes[NSForegroundColorAttributeName] = self.highlightedTextColor;
        }
        else if (self.textColor != nil) {
            attributes[NSForegroundColorAttributeName] = self.textColor;
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        paragraphStyle.alignment = self.textAlignment;
        attributes[NSParagraphStyleAttributeName] = paragraphStyle;
        
        if (!NSEqualSizes(self.shadowOffset, NSZeroSize) && self.shadowColor != nil) {
            NSShadow *shadow = [[NSShadow alloc] init];
            [shadow setShadowBlurRadius:0.0];
            [shadow setShadowColor:self.shadowColor];
            [shadow setShadowOffset:self.shadowOffset];
            attributes[NSShadowAttributeName] = shadow;
        }
        
        _attributedString = [[NSAttributedString alloc] initWithString:(self.text != nil ? self.text : @"") attributes:attributes];
    }
    return _attributedString;
}

- (void)drawTextInRect:(CGRect)rect {
    [[self attributedString] drawInRect:rect];
}

- (BOOL)isOpaque {
    return (self.backgroundColor != nil) && ([self.backgroundColor alphaComponent] == 1.0);
}


#pragma mark -
#pragma mark Metrics

- (NSSize)intrinsicContentSize {
    return [self sizeThatFits:self.bounds.size];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGRect boundingRect = [[self attributedString] boundingRectWithSize:size options:0];
    return NSMakeSize(boundingRect.size.width, boundingRect.size.height);
}

- (void)sizeToFit {
    [self setFrameSize:[self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)]];
}

- (CGFloat)baselineOffsetFromBottom {
    CGRect boundingRect = [[self attributedString] boundingRectWithSize:self.bounds.size options:0];
    return self.bounds.size.height - boundingRect.origin.y;
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
