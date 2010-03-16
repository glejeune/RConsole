# KETextField.rb
# RConsole
#
# Created by greg on 15/03/10.
# Copyright 2010 Grégoire Lejeune. All rights reserved.

class KETextField < NSTextField
  def performKeyEquivalent( event )
	keyEquiv = event.charactersIgnoringModifiers
	eventFlags = (self.modifierFlags & NSDeviceIndependentModifierFlagsMask)
	
	NSLog("keyEvent: %@", aKeyEquiv);
    NSLog("characters: %@", event.characters);
    NSLog("charactersIgnoringModifiers: %@", keyEquiv);
    NSLog("deviceIndependentModifierFlags: %d", eventFlags);
    NSLog("NSControlKeyMask: %d, %d", ((eventFlags & NSControlKeyMask) != 0), NSControlKeyMask);
    NSLog("NSAlternateKeyMask: %d, %d", ((eventFlags & NSAlternateKeyMask) != 0), NSAlternateKeyMask);
    NSLog("NSShiftKeyMask: %d, %d", ((eventFlags & NSShiftKeyMask) != 0), NSShiftKeyMask);
    NSLog("NSAlphaShiftKeyMask: %d, %d", ((eventFlags & NSAlphaShiftKeyMask) != 0), NSAlphaShiftKeyMask);
    NSLog("NSCommandKeyMask: %d, %d", ((eventFlags & NSCommandKeyMask) != 0), NSCommandKeyMask);
  end
end