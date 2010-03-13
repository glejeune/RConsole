//
//  Spaces.m
//  RConsole
//
//  Created by greg on 12/03/10.
//  Copyright 2010 Grégoire Lejeune. All rights reserved.
//

#import "Spaces.h"

@implementation Spaces

- (NSInteger)spaceNumber {
	NSInteger space = -1;
	CGSGetWorkspace(_CGSDefaultConnection(), &space);
	return space;
}

- (NSInteger)getSpaceNumberOfWindow:(NSWindow *)win {
	NSInteger windowId = [win windowNumber];
	NSInteger space = -1;
	CGSGetWindowWorkspace(_CGSDefaultConnection(), windowId, &space);
	return space;
}

- (void)moveWindowToCurrentSpace:(NSWindow *)win {
	[self moveWindow:win toSpaceNumber:[self spaceNumber]];
}

- (void)moveWindow:(NSWindow *)win toSpaceNumber:(NSInteger)space {
	NSInteger windowId = [win windowNumber];
	if(windowId != -1) {
		CGSMoveWorkspaceWindowList(_CGSDefaultConnection(), &windowId, 1, space);
	}
}
@end
