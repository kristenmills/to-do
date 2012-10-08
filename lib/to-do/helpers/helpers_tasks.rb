module Todo
	module Helpers
		module Tasks
			extend self

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
