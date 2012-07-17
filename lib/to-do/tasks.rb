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
			if !list
				Database.execute("INSERT INTO Lists (Name, Total) VALUES('" + Config[:working_list_name] +  "', 0)")
			end
			count = list ? list[0][0]+1 : 1
			DATABASE.execute "INSERT INTO Tasks (Task_number, Name, Completed) VALUES('" + count.to_s + "', '" + task + "', 0)"
			list_id = list[0][1]
			task_id = DATABASE.last_insert_row_id 
			DATABASE.execute "INSERT INTO Task_list VALUES(" + task_id.to_s + ", " + list_id.to_s + ")"
			DATABASE.execute "UPDATE Lists SET Total="+ count.to_s + " WHERE Id = " + list_id.to_s
		end

		# finish the task. task is either a case insensitive task on the list or
		# the task number. Prints out either the task is not in the list or that i
		# succesfully finished the task
		#
		# @param task either a task number or task name to finish
		# @param [Bool] is_num if the task param represents the task number, true. 
		# false if it is the task name
		def finish task, is_num
			list = DATABASE.execute("SELECT Id FROM Lists WHERE Name = '" + Config[:working_list_name] + "'")
			list_id = list[0][0]
			names = DATABASE.execute("SELECT * from Tasks WHERE Id IN 
					(SELECT Task_ID FROM Task_list WHERE List_Id IN 
						(SELECT Id FROM Lists WHERE Name='"+Config[:working_list_name]+"'))")
			if is_num
				if names.map{|t| t[1]}.include? task.to_i
					task_array = names.find{|t| t[1] == task.to_i}
					DATABASE.execute "Update Tasks SET Completed=1 WHERE Id=" + task_array[0].to_s
				else
					puts "Task ##{task} is not in the list or already completed."
				end
			else
				if names.map{|t| t[2].downcase}.include? task.downcase
					task_array = names.find{|t| t[2].downcase == task.downcase}
					DATABASE.execute "Update Tasks SET Completed=1 WHERE Id=" + task_array[0].to_s
				else
					puts "Task #{task} is not in the list."
				end
			end
		end
	end	
end