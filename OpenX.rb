# OpenX.rb
# RConsole
#
# Created by greg on 15/03/10.
# Copyright 2010 Grégoire Lejeune. All rights reserved.

class OpenX
	# OpenX.open( "/path/to/my/command", ["args1", "arg2"] ) { |output, error, task|
	#   input.puts "Hello"
	#   puts output output.gets
	#   Process.Kill 'KILL', tasl.processIdentifier
	# }
	def self.open( command, args = [], &block )
		new.open( command, args, &block )
	end

	def initialize
	end

	def open( command, args = [], &block )
		inputPipe = NSPipe.pipe()
		inputFileHandle = inputPipe.fileHandleForWriting()
		
		outputPipe = NSPipe.pipe()
		outputFileHandle = outputPipe.fileHandleForReading()
		
		errorPipe = NSPipe.pipe()
		errorFileHandle = errorPipe.fileHandleForReading()
		
		task = NSTask.alloc.init()
		task.setStandardInput(inputPipe)
		task.setStandardOutput(outputPipe)
		task.setStandardError(errorPipe)
		task.setLaunchPath(command)
		task.setArguments(args)
		
		task.launch()
		
		outputData = outputPipe.fileHandleForReading.readDataToEndOfFile
		outputString = NSString.alloc.initWithData(outputData, encoding:NSUTF8StringEncoding)

		errorData = errorPipe.fileHandleForReading.readDataToEndOfFile
		errorString = NSString.alloc.initWithData(errorData, encoding:NSUTF8StringEncoding)

		yield( outputString, errorString, task )
	end
end
