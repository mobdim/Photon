//
//  PXTableViewCell.m
//  Photon
//
//  Created by Logan Collins on 3/1/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "PXTableViewCell.h"


@implementation PXTableViewCell

@synthesize icon;
@synthesize selectedIcon;
@synthesize iconSize;
@synthesize iconAlpha;
@synthesize subtitle;
@synthesize subtitleFont;
@synthesize subtitleColor;
@synthesize badgeString;
@synthesize badgeColor;
@synthesize badgeStyle;
@synthesize badgeMenu;

- (id)initTextCell:(NSString *)string {
	self = [super initTextCell:string];
	if (self) {
        iconSize = NSMakeSize(16.0, 16.0);
        iconAlpha = 1.0;
        badgeStyle = PXTableViewCellBadgeStyleCapsule;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		icon = [coder decodeObjectForKey:@"icon"];
		selectedIcon = [coder decodeObjectForKey:@"selectedIcon"];
        if ([coder containsValueForKey:@"iconSize"]) {
            iconSize = [coder decodeSizeForKey:@"iconSize"];
        }
        else {
            iconSize = NSMakeSize(16.0, 16.0);
        }
        if ([coder containsValueForKey:@"iconAlpha"]) {
            iconAlpha = [coder decodeDoubleForKey:@"iconAlpha"];
        }
        else {
            iconAlpha = 1.0;
        }
        subtitle = [coder decodeObjectForKey:@"subtitle"];
        subtitleFont = [coder decodeObjectForKey:@"subtitleFont"];
        subtitleColor = [coder decodeObjectForKey:@"subtitleColor"];
		badgeString = [coder decodeObjectForKey:@"badgeString"];
        badgeColor = [coder decodeObjectForKey:@"badgeColor"];
        badgeStyle = [coder decodeIntegerForKey:@"badgeStyle"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	[coder encodeObject:icon forKey:@"icon"];
	[coder encodeObject:selectedIcon forKey:@"selectedIcon"];
    [coder encodeSize:iconSize forKey:@"iconSize"];
    [coder encodeDouble:iconAlpha forKey:@"iconAlpha"];
    [coder encodeObject:subtitle forKey:@"subtitle"];
    [coder encodeObject:subtitleFont forKey:@"subtitleFont"];
    [coder encodeObject:subtitleColor forKey:@"subtitleColor"];
	[coder encodeObject:badgeString forKey:@"badgeString"];
    [coder encodeObject:badgeColor forKey:@"badgeColor"];
    [coder encodeInteger:badgeStyle forKey:@"badgeStyle"];
}

- (id)copyWithZone:(NSZone *)zone {
	PXTableViewCell *cell = [super copyWithZone:zone];
	cell->icon = [icon copyWithZone:zone];
	cell->selectedIcon = [selectedIcon copyWithZone:zone];
    cell->iconSize = iconSize;
    cell->iconAlpha = iconAlpha;
    cell->subtitle = [subtitle copyWithZone:zone];
    cell->subtitleFont = [subtitleFont copyWithZone:zone];
    cell->subtitleColor = [subtitleColor copyWithZone:zone];
	cell->badgeString = [badgeString copyWithZone:zone];
    cell->badgeColor = [badgeColor copyWithZone:zone];
    cell->badgeStyle = badgeStyle;
    cell->badgeMenu = badgeMenu;
	return cell;
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	if (icon != nil) {
		NSRect textFrame, imageFrame;
		NSDivideRect(aRect, &imageFrame, &textFrame, (iconSize.width ? iconSize.width : [icon size].width) + 8.0, NSMinXEdge);
		[super selectWithFrame:NSInsetRect(textFrame, 0.0, 3.0) inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	}
    else {
		[super selectWithFrame:NSInsetRect(aRect, 2.0, 2.0) inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	}
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
    
    return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView {
    
    return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
    
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	CGFloat xMinOffset = 2.0;
	CGFloat xMaxOffset = 2.0;
	
	if (icon != nil) {
        xMinOffset += 2.0;
        
        NSImage *theImage = nil;
        if ([self isHighlighted] && selectedIcon != nil) {
            theImage = [selectedIcon copy];
        }
        else {
            theImage = [icon copy];
        }
        
        NSSize imageSize = iconSize;
        if (NSEqualSizes(iconSize, NSZeroSize)) {
            imageSize = [theImage size];
        }
        
		NSRect iconRect = NSMakeRect(cellFrame.origin.x + xMinOffset, cellFrame.origin.y + round((cellFrame.size.height - imageSize.height) / 2.0), imageSize.width, imageSize.height);
		
        NSImageCell *imageCell = [[NSImageCell alloc] initImageCell:theImage];
        [imageCell setBackgroundStyle:NSBackgroundStyleLight];
        [imageCell drawWithFrame:iconRect inView:controlView];
		
		xMinOffset += imageSize.width + 2.0;
	}
	
	if (badgeString != nil || badgeMenu != nil) {
        if (badgeStyle == PXTableViewCellBadgeStyleCapsule) {
            CGFloat badgeWidth = 0.0;
            
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            [attributes setObject:[NSFont fontWithName:@"Helvetica-Bold" size:11.0] forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [para setAlignment:NSCenterTextAlignment];
            [attributes setObject:para forKey:NSParagraphStyleAttributeName];
            
            if (badgeString != nil) {
                if ([self isHighlighted]) {
                    if ([[controlView window] isMainWindow] || ([[controlView window] isSheet] && [[controlView window] isKeyWindow])) {
                        if (badgeColor != nil) {
                            [attributes setObject:badgeColor forKey:NSForegroundColorAttributeName];
                        }
                        else {
                            [attributes setObject:[NSColor colorWithCalibratedHue:0.60 saturation:0.32 brightness:0.74 alpha:1.0] forKey:NSForegroundColorAttributeName];
                        }
                    }
                    else {
                        [attributes setObject:[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0] forKey:NSForegroundColorAttributeName];
                    }
                }
                else {
                    [attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
                }
                
                badgeWidth += [badgeString sizeWithAttributes:attributes].width + 14.0;
            }
            
            if (badgeMenu != nil) {
                badgeWidth += 8.0;
            }
            
            NSRect displayRect = NSMakeRect(NSMaxX(cellFrame) - (badgeWidth + 4.0 + xMaxOffset),
                                            NSMinY(cellFrame) + round((NSHeight(cellFrame) - 14.0) / 2.0),
                                            badgeWidth,
                                            14.0);
            
            NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:displayRect xRadius:7.0 yRadius:7.0];
            
            if ([self isHighlighted]) {
                [[NSColor whiteColor] set];
                [path fill];
            }
            else if ([[controlView window] isMainWindow] || ([[controlView window] isSheet] && [[controlView window] isKeyWindow])) {
                if (badgeColor != nil) {
                    [badgeColor set];
                }
                else {
                    [[NSColor colorWithCalibratedHue:0.60 saturation:0.32 brightness:0.74 alpha:1.0] set];
                }
                [path fill];
            }
            else {
                [[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0] set];
                [path fill];
            }
            
            
            // Draw badge text
            if (badgeString != nil) {
                NSRect textRect =  NSMakeRect(displayRect.origin.x,
                                              displayRect.origin.y + floor((NSHeight(displayRect) - [badgeString sizeWithAttributes:attributes].height) / 2.0),
                                              [badgeString sizeWithAttributes:attributes].width + 14.0,
                                              [badgeString sizeWithAttributes:attributes].height);
                [badgeString drawInRect:textRect withAttributes:attributes];
            }
            
            // Draw badge menu arrow
            if (badgeMenu != nil) {
                NSBezierPath *arrowPath = [NSBezierPath bezierPath];
                [arrowPath moveToPoint:NSMakePoint(NSMaxX(displayRect) - 10.0, NSMinY(displayRect) + 6.0)];
                [arrowPath lineToPoint:NSMakePoint(NSMaxX(displayRect) - 4.0, NSMinY(displayRect) + 6.0)];
                [arrowPath lineToPoint:NSMakePoint(NSMaxX(displayRect) - 7.0, NSMinY(displayRect) + 10.0)];
                [arrowPath closePath];
                
                if ([self isHighlighted]) {
                    if ([[controlView window] isMainWindow] || ([[controlView window] isSheet] && [[controlView window] isKeyWindow])) {
                        if (badgeColor != nil) {
                            [badgeColor set];
                        }
                        else {
                            [[NSColor colorWithCalibratedHue:0.60 saturation:0.32 brightness:0.74 alpha:1.0] set];
                        }
                    }
                    else {
                        [[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0] set];
                    }
                }
                else {
                    [[NSColor whiteColor] set];
                }
                
                [arrowPath fill];
            }
            
            xMaxOffset += badgeWidth + 6.0;
        }
        else if (badgeStyle == PXTableViewCellBadgeStyleBox) {
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            [attributes setObject:[NSFont boldSystemFontOfSize:8.0] forKey:NSFontAttributeName];
            
            NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            [para setAlignment:NSCenterTextAlignment];
            [attributes setObject:para forKey:NSParagraphStyleAttributeName];
            
            if (![self isHighlighted]) {
                if ([[controlView window] isMainWindow] || ([[controlView window] isSheet] && [[controlView window] isKeyWindow])) {
                    if (badgeColor != nil) {
                        [attributes setObject:badgeColor forKey:NSForegroundColorAttributeName];
                    }
                    else {
                        [attributes setObject:[NSColor colorWithCalibratedHue:0.60 saturation:0.32 brightness:0.74 alpha:1.0] forKey:NSForegroundColorAttributeName];
                    }
                }
                else {
                    [attributes setObject:[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0] forKey:NSForegroundColorAttributeName];
                }
            }
            else {
                [attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
            }
            
            NSRect displayRect = NSMakeRect(NSMaxX(cellFrame) - ([badgeString sizeWithAttributes:attributes].width + 10.0 + xMaxOffset),
                                            NSMinY(cellFrame) + round((NSHeight(cellFrame) - 12.0) / 2.0),
                                            [badgeString sizeWithAttributes:attributes].width + 6.0,
                                            12.0);
            
            NSRect insetRect = displayRect;
            insetRect.origin.y += floor((NSHeight(displayRect) - [badgeString sizeWithAttributes:attributes].height) / 2.0);
            insetRect.size.height = [badgeString sizeWithAttributes:attributes].height;
            
            NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(displayRect, 0.5, 0.5)];
            
            if ([self isHighlighted]) {
                [[NSColor whiteColor] set];
                [path stroke];
            }
            else if ([[controlView window] isMainWindow] || ([[controlView window] isSheet] && [[controlView window] isKeyWindow])) {
                if (badgeColor != nil) {
                    [badgeColor set];
                }
                else {
                    [[NSColor colorWithCalibratedHue:0.60 saturation:0.32 brightness:0.74 alpha:1.0] set];
                }
                [path stroke];
            }
            else {
                [[NSColor colorWithCalibratedHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0] set];
                [path stroke];
            }
            
            [badgeString drawInRect:insetRect withAttributes:attributes];
            
            xMaxOffset += NSWidth(displayRect) + 6.0;
        }
	}
    
	NSSize titleSize = [[self attributedStringValue] size];
	NSRect titleRect = NSMakeRect(cellFrame.origin.x + xMinOffset, cellFrame.origin.y + round((cellFrame.size.height - titleSize.height) / 2.0), cellFrame.size.width - (xMinOffset + xMaxOffset), titleSize.height);
	
    if (self.subtitle) {
        NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [para setLineBreakMode:NSLineBreakByTruncatingMiddle];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           (self.subtitleFont ? self.subtitleFont : [NSFont systemFontOfSize:11.0]), NSFontAttributeName,
                                           (self.subtitleColor ? self.subtitleColor : [NSColor colorWithCalibratedWhite:0.6 alpha:1.0]), NSForegroundColorAttributeName,
                                           para, NSParagraphStyleAttributeName,
                                           nil];
        
        if ([(NSTableView *)controlView selectionHighlightStyle] == NSTableViewSelectionHighlightStyleSourceList) {
            if ([self isHighlighted]) {
                [dictionary setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
            }
        }
        else {
            if ([self isHighlighted] && [[controlView window] firstResponder] == controlView && [[controlView window] isKeyWindow]) {
                [dictionary setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
            }
        }
        
        NSSize subtitleSize = [[self subtitle] sizeWithAttributes:dictionary];
        
        CGFloat bothLabelsHeight = titleSize.height + subtitleSize.height;
        NSRect bothLabelsRect = NSMakeRect(cellFrame.origin.x + xMinOffset, cellFrame.origin.y + round((cellFrame.size.height - bothLabelsHeight) / 2.0), cellFrame.size.width - (xMinOffset + xMaxOffset), bothLabelsHeight);
        
        NSRect subtitleRect = NSMakeRect(cellFrame.origin.x + xMinOffset, bothLabelsRect.origin.y + round(bothLabelsRect.size.height - subtitleSize.height), cellFrame.size.width - (xMinOffset + xMaxOffset), subtitleSize.height);
        
        [[self subtitle] drawInRect:NSInsetRect(subtitleRect, 2.0, 0.0) withAttributes:dictionary];
        
        titleRect.origin.y = bothLabelsRect.origin.y;
    }
    
	[super drawInteriorWithFrame:titleRect inView:controlView];
}

@end
