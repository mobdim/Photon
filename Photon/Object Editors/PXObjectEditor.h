//
//  PXObjectEditor.h
//  Photon
//
//  Created by Logan Collins on 8/14/12.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/* LCObjectEditor is an abstract class that displays a window to edit objects
 */
@interface PXObjectEditor : NSWindowController

// Running
- (void)beginWithCompletionHandler:(void (^)(NSInteger result))handler;
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger result))handler;

// Actions
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

// NSEditor and NSEditorRegistration
- (BOOL)commitEditing;
- (void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo;
- (void)discardEditing;
- (void)objectDidBeginEditing:(id)editor;
- (void)objectDidEndEditing:(id)editor;

@end
