module Todo
	module Helpers

		# Helper methods used in the Todo::Tasks module
		module Tasks
			extend self

			# Update a task
			#
			# @param [Bool] is_num is the task a number
			# @param [Dataset] names a dataset of all the tasks in the working list
			# @param task the task name or number that we are updating
			# @param [Symbol] key the key we are updating
			# @param [Integer] value the value that we are changing it too. 
			def update_task is_num, names, task, key, value
				if is_num
					found_task = names[:Task_number => task]
					if found_task
						Helpers::DATABASE[:Tasks].filter(:Id => found_task[:Id]).update(key => value)
					else
						puts "Task ##{task} is not in the list."
					end
				else
					found_task = names.with_sql("SELECT * FROM :table WHERE Name = :task COLLATE NOCASE",:table=>names, :task=>task).first
					if found_task
						Helpers::DATABASE[:Tasks].filter(:Id => found_task[:Id]).update(key => value)
					else
						puts "Task '#{task}' is not in the list."
					end
				end
			end
		end
	end
end
