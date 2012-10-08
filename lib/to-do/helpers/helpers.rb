module Todo
	#A module that contains helper methods 
	module Helpers
		extend self
		DATABASE = Sequel.sqlite Todo::Config[:task_database]
	end
end

require File.join(File.dirname(__FILE__), 'helpers_CLI') 
require File.join(File.dirname(__FILE__), 'helpers_Tasks') 