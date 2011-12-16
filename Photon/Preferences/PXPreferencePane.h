//
//  PXPreferencePane.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PXViewController.h>


/* An PXPreferencePane object defines an individual preference pane
 */
@interface PXPreferencePane : PXViewController

@property (copy) NSString *identifier;

@end
