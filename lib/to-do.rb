require File.join(File.dirname(__FILE__), 'to-do', 'config')
require File.join(File.dirname(__FILE__), 'to-do', 'list')
if !File.exists?(File.join(ENV['HOME'], '.to-do'))
	Dir.mkdir(File.join(ENV['HOME'], '.to-do'))
	Todo::Config.write
	Dir.mkdir(Todo::Config[:lists_directory])
end
require File.join(File.dirname(__FILE__), 'to-do', 'cli')

# Todo is the main namespace that all of the other modules and classes are a 
# part of
module Todo
end