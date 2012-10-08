module Todo
	#A module that contains helper methods 
	module Helpers
		extend self
		DATABASE = Sequel.sqlite Todo::Config[:task_database]

		def task_names 
			Helpers::DATABASE[:Tasks].join(:Task_list, :Tasks__Id => :Task_list__Task_Id).join(
			:Lists, :Lists__Id => :Task_list__List_id).select(:Tasks__Id, :Tasks__Task_number, 
			:Tasks__Name, :Tasks__Completed, :Tasks__Priority).filter(:Lists__Name => Config[:working_list_name])
		end
	end
end

require File.join(File.dirname(__FILE__), 'helpers_CLI') 
require File.join(File.dirname(__FILE__), 'helpers_tasks') 