# RConsole.rb
# RConsole
#
# Created by greg on 10/03/10.
# Copyright 2010 Grégoire Lejeune. All rights reserved.

require 'tempfile'

SH_NULL = nil
SH_STRING = NSColor.grayColor
SH_COMMENT = NSColor.colorWithCalibratedRed 0.09, :green => 0.62, :blue => 0.22, :alpha => 1
SH_RESERVED = NSColor.redColor
SH_CONST = NSColor.blueColor
SH_NUMBER = NSColor.orangeColor
SH_CLASSVAR = NSColor.colorWithCalibratedRed 0.45, :green => 0.12, :blue => 0.44, :alpha => 1


class RConsole
	attr_accessor :main_window, :result_window
	attr_accessor :console, :output
	attr_accessor :interpreters
	attr_accessor :status_bar_menu

	attr_accessor :preferences_window
	attr_accessor :interpreters_table

	def initialize
		@words = %w{
			alias and BEGIN begin break case class def defined? do else elsif
			END end ensure false for if in module next nil not or redo rescue
			retry return self super then true undef unless until when while
			yield 
		}
		
		# Load preferences
		userDefaultsValuesPath=NSBundle.mainBundle.pathForResource("UserDefaults", ofType:"plist")
		userDefaultsValuesDict=NSDictionary.dictionaryWithContentsOfFile(userDefaultsValuesPath)

		@userDefaultsPrefs = NSUserDefaults.standardUserDefaults
		@userDefaultsPrefs.registerDefaults(userDefaultsValuesDict)
		
		# Make interpreters list
		@interpreters_list = @userDefaultsPrefs.arrayForKey("Interpreters").clone
		
		# Get StatusBar menu image
		@menuImage = NSImage.imageNamed("rConsole.png")
		
		# Main Window active
		@mainWindowIsActive = false
	end
	
	def awakeFromNib
		self.console.textStorage.delegate = self
		self.interpreters.selectItemAtIndex(0)
		
		self.console.font = NSFont.fontWithName "Courier", :size => 12
		self.output.font = NSFont.fontWithName "Courier", :size => 14
	end
	
	def applicationDidFinishLaunching( aNotification )
		# Display StatusBar Menu
		bar = NSStatusBar.systemStatusBar()
		@statusBarItem = bar.statusItemWithLength(NSVariableStatusItemLength)
		@statusBarItem.setHighlightMode(true)
		@statusBarItem.setMenu(self.status_bar_menu)
		@statusBarItem.setImage(@menuImage)
		
		# Initialize HotKey
		@hotKey = EventHotkey.new
		@hotKey.delegate = self
		@hotKey.addShortcut
		
		# Get Current Space
		@space = Spaces.new
	end
	
	def hotkeyWasPressed		
		currentSpace = @space.spaceNumber
		mainWindowSpace = @space.getSpaceNumberOfWindow(main_window)
		
		if mainWindowSpace != currentSpace
			@space.moveWindowToCurrentSpace( main_window )
			self.showMainWindow(self)
		else
			self.hideMainWindow(self)
		end
		
		NSApp.activateIgnoringOtherApps(true)
	end
	
	def windowShouldClose(win)
		win.orderOut(self)
		return false
	end
	
	# -- Syntac Highlighting --------------------------------------
	def textStorageDidProcessEditing(notification)
		textStorage = notification.object
		string = textStorage.string
		area = textStorage.editedRange
		length = string.length
		areamax = NSMaxRange(area)
		found = NSRange.new

		whiteSpaceSet = NSCharacterSet.characterSetWithCharactersInString "\n\t\ .(){}[]:|" # whitespaceAndNewlineCharacterSet
		
		start = string.rangeOfCharacterFromSet whiteSpaceSet,
			:options => NSBackwardsSearch,
			:range => NSMakeRange(0, area.location)
		if( start.location == NSNotFound )
			start.location = 0;
		else
			start.location = NSMaxRange(start);
		end
		
		_end = string.rangeOfCharacterFromSet whiteSpaceSet,
			:options => 0,
			:range => NSMakeRange(areamax, length - areamax)
		if( _end.location == NSNotFound )
			_end.location = length;
		end
		
		area = NSMakeRange(start.location, _end.location - start.location);
		return if area.length == 0 # bail early
		
		# remove the old colors
		textStorage.removeAttribute NSForegroundColorAttributeName, :range => area
		
		# add new colors
		while( area.length > 0 )
			# find the next word
			_end = string.rangeOfCharacterFromSet whiteSpaceSet,
				:options => 0,
				:range => area
			if _end.location == NSNotFound
				_end = found = area
			else
				found.length = _end.location - area.location
				found.location = area.location
			end
			
			word = string.substringWithRange found
			
			# color as necessary
			if @words.include?(word)
				textStorage.addAttribute NSForegroundColorAttributeName,
					:value => SH_RESERVED,
					:range => found
			elsif /^[A-Z]/.match word[0]
				textStorage.addAttribute NSForegroundColorAttributeName,
					:value => SH_CONST,
					:range => found
			elsif word[0] == "@"
				textStorage.addAttribute NSForegroundColorAttributeName,
					:value => SH_CLASSVAR,
					:range => found
			elsif /^[0-9_\.]*$/.match(word)
				textStorage.addAttribute NSForegroundColorAttributeName,
					:value => SH_NUMBER,
					:range => found
			end
			
			# adjust our area
			areamax = NSMaxRange(_end)
			area.length -= areamax - area.location
			area.location = areamax
		end
		
		# Color string & comment	
		strFound = SH_NULL
		colorRange = NSRange.new

		(0...NSMaxRange(area)).each { |i|
			if string[i] == '"'
				if strFound == SH_NULL
					colorRange.location = i
					strFound = SH_STRING
				elsif strFound == SH_STRING
					colorRange.length = i - colorRange.location + 1
					textStorage.addAttribute NSForegroundColorAttributeName,
						:value => strFound,
						:range => colorRange
					strFound = SH_NULL
				end
			elsif string[i] == "#" and strFound == SH_NULL
				colorRange.location = i
				strFound = SH_COMMENT
			elsif string[i] == "\n" and strFound == SH_COMMENT
				colorRange.length = i - colorRange.location + 1
				textStorage.addAttribute NSForegroundColorAttributeName,
					:value => strFound,
					:range => colorRange
				strFound = SH_NULL
			end
		}
	end
	
	# -- Interpreters Datasource --------------------------------------
	def numberOfItemsInComboBox(aComboBox)
		return @interpreters_list.size
	end
	
	def comboBox(aComboBox, objectValueForItemAtIndex:index)
		return @interpreters_list[index]["name"]
	end

	# -- Preferences Datasource --------------------------------------
	def numberOfRowsInTableView(aTable)
		return @interpreters_list.size
	end
	
	def tableView( aTable, objectValueForTableColumn:aColumn, row:aRow)
		return @interpreters_list[aRow][aColumn.identifier]
	end

	# -- Result Window --------------------------------------
	def closeResultWindow(sender)
		NSApp.endSheet(result_window)
		result_window.orderOut(sender)
	end
	
	# -- Preferences Window --------------------------------------
	def closePreferencesWindow(sender)
		NSApp.endSheet(preferences_window)
		preferences_window.orderOut(sender)
		@userDefaultsPrefs.setObject(@interpreters_list, forKey:"Interpreters")
		@userDefaultsPrefs.synchronize
		self.interpreters.reloadData
		self.interpreters.selectItemAtIndex(0)
	end
	
	# -- MainWindow Actions --------------------------------------
	def run(sender)
		# Get the ruby interpreter to use
		rubyInterpreter = @interpreters_list[interpreters.indexOfSelectedItem]["path"]
		
		# Show Main Window 
		self.showMainWindow(sender)
		# Show the result window
		NSApp.beginSheet(result_window, modalForWindow:main_window, modalDelegate:nil, didEndSelector:nil, contextInfo:nil)

		# Get the code and save it in a temp file
		the_code = self.console.textStorage.string
		t = Tempfile::open( "rConsole" )
        t.print( the_code )
        t.close

		# Run !
		begin
			IO.popen("#{rubyInterpreter} #{t.path} 2>&1") { |o|
				self.output.textStorage.mutableString.string = o.read.gsub( t.path, "RConsole" )
			}
		rescue => e
			self.output.textStorage.mutableString.string = e.message
		end
	ensure
		t.unlink
	end
	
	def showPreferencesWindow(sender)
		self.showMainWindow(sender)
		NSApp.beginSheet(preferences_window, modalForWindow:main_window, modalDelegate:nil, didEndSelector:nil, contextInfo:nil)
	end
	
	def showMainWindow(sender)
		@mainWindowIsActive = true
		self.main_window.makeKeyAndOrderFront(self)
	end

	def hideMainWindow(sender)
		@mainWindowIsActive = false
		self.main_window.orderOut(self)
	end
	
	# -- PreferencesWindow Actions ---------------------------------
	def addRubyInterpreter(sender)
		@interpreters_list << {"name" => "Ruby", "path" => ""}
		self.interpreters_table.reloadData
		self.interpreters_table.selectRow(@interpreters_list.size - 1, byExtendingSelection:false)
		self.interpreters_table.editColumn(0, row:(@interpreters_list.size - 1), withEvent:nil, select:true)
	end
	
	def removeRubyInterpreter(sender)
		if( self.interpreters_table.selectedRow < 0 or self.interpreters_table.selectedRow >= @interpreters_list.size)
			return
		end
		@interpreters_list.delete_at(self.interpreters_table.selectedRow)
		self.interpreters_table.reloadData
	end
	
	def tableView(aTableView, setObjectValue:anObject, forTableColumn:aTableColumn, row:rowIndex)
		@interpreters_list[rowIndex][aTableColumn.identifier] = anObject
		self.interpreters_table.reloadData
	end
end