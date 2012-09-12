//
//  NSColor+PhotonAdditions.m
//  Photon
//
//  Created by Logan Collins on 8/2/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "NSColor+PhotonAdditions.h"


@implementation NSColor (PhotonAdditions)

+ (NSColor *)px_colorWithCGColor:(CGColorRef)cgColor {
	CGColorSpaceRef colorSpace = CGColorGetColorSpace(cgColor);
	NSUInteger componentCount = CGColorGetNumberOfComponents(cgColor);
	const CGFloat *components = CGColorGetComponents(cgColor);
	
	NSColorSpace *newColorSpace = [[[NSColorSpace alloc] initWithCGColorSpace:colorSpace] autorelease];
	NSColor *color = [NSColor colorWithColorSpace:newColorSpace components:components count:componentCount];
	
	return color;
}

- (CGColorRef)px_CGColor {
	CGColorSpaceRef colorSpace = [[self colorSpace] CGColorSpace];
	NSUInteger count = [[self colorSpace] numberOfColorComponents];
	CGFloat *components = malloc(sizeof(CGFloat) * count);
	[self getComponents:components];
	
	CGColorRef cgColor = CGColorCreate(colorSpace, components);
	
	free(components);
	
	return (CGColorRef)[(id)cgColor autorelease];
}

@end
