//
//  EventHotkey.h
//  RConsole
//
//  Created by greg on 12/03/10.
//  Copyright 2010 Grégoire Lejeune. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface EventHotkey : NSObject
{
    id delegate;
}
@property (assign) id delegate;
- (void) addShortcut;
- (void) hotkeyWasPressed;
@end
OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);