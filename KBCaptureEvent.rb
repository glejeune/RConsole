# KBCaptureEvent.rb
# RConsole
#
# Created by greg on 16/03/10.
# Copyright 2010 Grégoire Lejeune. All rights reserved.

class KBCaptureEvent < NSView
  def acceptsFirstResponder
    true
  end
  
  def keyDown(event)
    require 'pp'
    pp event
    
    characters = event.characters
    pp characters
    
    kk = event.keyCode
    pp kk
    
    xx = event.modifierFlags
    pp xx
  end
end
