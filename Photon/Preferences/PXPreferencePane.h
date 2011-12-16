//
//  PXPreferencePane.h
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Photon/PXViewController.h>


/*!
 * @class PXPreferencePane
 * @abstract An individual preference pane
 * 
 * @discussion
 * PXPreferencePane is a subclass of PXViewController that defines a pane
 * managed by a preferences controller.
 */
@interface PXPreferencePane : PXViewController <NSUserInterfaceItemIdentification>

/*!
 * @property identifier
 * @abstract The unique identifier of the preference pane
 * 
 * @discussion
 * The identifier must be unique within the context of a preference pane controller.
 * 
 * @result An NSString object
 */
@property (copy) NSString *identifier;

@end
