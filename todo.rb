#!/usr/bin/env ruby
require_relative 'cli.rb'

if ARGV.length == 0
	Todo::CLI.display
else
	case ARGV[0]
	when "-h","--help"
		Todo::CLI.help
	else
	end
end