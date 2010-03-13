//
//  EventHotkey.m
//  RConsole
//
//  Created by greg on 12/03/10.
//  Copyright 2010 Grégoire Lejeune. All rights reserved.
//

#import "EventHotkey.h"


@implementation EventHotkey
@synthesize delegate;

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData)
{
    if ( userData != NULL ) {
        id delegate = (id)userData;
        if ( delegate && [delegate respondsToSelector:@selector(hotkeyWasPressed)] ) {
			[delegate hotkeyWasPressed];
        }
    }
    return noErr;
}

- (void) addShortcut
{
    EventHotKeyRef myHotKeyRef;
    EventHotKeyID myHotKeyID;
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    if ( delegate == nil )
		delegate = self;
    EventTargetRef eventTarget = (EventTargetRef) GetEventMonitorTarget();
    InstallEventHandler(eventTarget, &myHotKeyHandler, 1, &eventType, (void *)delegate, NULL);
    myHotKeyID.signature='mhk1';
    myHotKeyID.id=1;
	// cmdKey+optionKey+controlKey+shiftKey
    RegisterEventHotKey(49, controlKey+shiftKey, myHotKeyID, eventTarget, 0, &myHotKeyRef);
}

- (void) hotkeyWasPressed {};
@end

void Init_EventHotkey(void) {}