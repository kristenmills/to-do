require File.join(File.dirname(__FILE__), 'config')
require 'fileutils'
require 'sqlite3'
module Todo

	# The module that contains methods for manipulating the database
	module Tasks
		extend self
		DATABASE = SQLite3::Database.new(Todo::Config[:task_database])
		def add task
			list = DATABASE.execute("SELECT Total, Id FROM Lists WHERE Name = '" + Config[:working_list_name] + "'")
			count = list ? list[0][0]+1 : 1
			DATABASE.execute "INSERT INTO Tasks (Task_number, Name, Completed) VALUES('" + count.to_s + "', '" + task + "', 0)"
			list_id = list[0][1]
			task_id = DATABASE.last_insert_row_id 
			DATABASE.execute "INSERT INTO Task_list VALUES(" + task_id.to_s + ", " + list_id.to_s + ")"
			DATABASE.execute "UPDATE Lists SET Total="+ count.to_s + " WHERE Id = " + list_id.to_s
		end
	end	
end