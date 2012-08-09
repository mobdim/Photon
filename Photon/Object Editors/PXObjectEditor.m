//
//  PXObjectEditor.m
//  Photon
//
//  Created by Logan Collins on 12/15/11.
//  Copyright (c) 2011 Sunflower Softworks. All rights reserved.
//

#import "PXObjectEditor.h"


@implementation PXObjectEditor {
    NSMutableArray *editors;
    void (^completionHandler)(NSInteger result);
}

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        editors = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark -
#pragma mark Running

- (void)beginWithCompletionHandler:(void (^)(NSInteger result))handler {
    NSInteger returnCode = [[NSApplication sharedApplication] runModalForWindow:[self window]];
    if (handler != nil) {
        handler(returnCode);
    }
}

- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger result))handler {
    completionHandler = [handler copy];
    [[NSApplication sharedApplication] beginSheet:[self window] modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)window returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [window orderOut:nil];
    
    if (completionHandler != nil) {
        completionHandler(returnCode);
        completionHandler = nil;
    }
}


#pragma mark -
#pragma mark NSEditor and NSEditorRegistration

- (NSObject *)_topEditor {
    // Return the most recently registered key-value binding editor. We never have to explicitly remove the editor from the list because editors remove themselves when asked to commit or discard changes. Be careful of the fact that -pointerAtIndex: might return NULL when running garbage-collected.
    NSObject *topEditor = nil;
    NSUInteger editorCount = [editors count];
    for (NSInteger index = editorCount - 1; index>=0; index--) {
        id editor = [editors objectAtIndex:index];
        if (editor) {
            topEditor = editor;
            break;
        }
    }
    return topEditor;
}

- (BOOL)commitEditing {
    BOOL committedEditing = YES;
    NSObject *topEditor;
    while ((topEditor = [self _topEditor])) {
        BOOL editorCommittedEditing = [topEditor commitEditing];
        if (!editorCommittedEditing) {
            committedEditing = NO;
            break;
        }
    }
    return committedEditing;
}

- (void)commitEditingWithDelegate:(id)delegate didCommitSelector:(SEL)didCommitSelector contextInfo:(void *)contextInfo {
    NSInvocation *originalDelegateInvocation = nil;
    NSMethodSignature *methodSignature = [delegate methodSignatureForSelector:didCommitSelector];
    if (methodSignature != nil) {
        originalDelegateInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [originalDelegateInvocation setTarget:delegate];
        [originalDelegateInvocation setSelector:didCommitSelector];
        PXObjectEditor *editor = self;
        [originalDelegateInvocation setArgument:&editor atIndex:2];
        [originalDelegateInvocation setArgument:&contextInfo atIndex:4];
    }
    
    NSObject *topEditor = [self _topEditor];
    if (topEditor) {
        [topEditor commitEditingWithDelegate:self didCommitSelector:@selector(_editor:didCommit:withOriginalDelegateInvocation:) contextInfo:(__bridge_retained void *)originalDelegateInvocation];
    }
    else {
        BOOL kYES = YES;
        [originalDelegateInvocation setArgument:&kYES atIndex:3];
        [originalDelegateInvocation invoke];
    }
}

- (void)_editor:(id)inEditor didCommit:(BOOL)inDidCommit context:(void *)context {
    NSInvocation *inOriginalDelegateInvocation = (__bridge_transfer NSInvocation *)context;
    NSObject *topEditor = [self _topEditor];
    if (inDidCommit && topEditor) {
        [topEditor commitEditingWithDelegate:self didCommitSelector:@selector(_editor:didCommit:withOriginalDelegateInvocation:) contextInfo:(__bridge_retained void *)inOriginalDelegateInvocation];
    }
    else {
        [inOriginalDelegateInvocation setArgument:&inDidCommit atIndex:3];
        [inOriginalDelegateInvocation invoke];
    }
}

- (void)discardEditing {
    NSObject *topEditor;
    while ((topEditor = [self _topEditor])) {
        [topEditor discardEditing];
    }
}

- (void)objectDidBeginEditing:(id)editor {
    [editors addObject:editor];
}

- (void)objectDidEndEditing:(id)editor {
    [editors removeObject:editor];
}


#pragma mark -
#pragma mark Actions

- (IBAction)ok:(id)sender {
    [self commitEditingWithDelegate:self didCommitSelector:@selector(_editor:didCommit:contextInfo:) contextInfo:nil];
}

- (void)_editor:(id)editor didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo {
    if (didCommit) {
        [[self window] makeFirstResponder:nil];
        if ([[self window] isSheet]) {
            [[NSApplication sharedApplication] endSheet:[self window] returnCode:NSOKButton];
        }
        else {
            [[NSApplication sharedApplication] stopModalWithCode:NSOKButton];
        }
    }
}

- (IBAction)cancel:(id)sender {
    if ([self respondsToSelector:@selector(discardEditing)]) {
        [self discardEditing];
    }
    
    if ([[self window] isSheet]) {
        [[NSApplication sharedApplication] endSheet:[self window] returnCode:NSCancelButton];
    }
    else {
        [[NSApplication sharedApplication] stopModalWithCode:NSCancelButton];
    }
}

@end
