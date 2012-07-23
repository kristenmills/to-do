module Todo

	# The module that contains methods for manipulating the database
	module Tasks
		extend self
		DATABASE = Sequel.sqlite Todo::Config[:task_database]

		# Adds the tast to the list
		# 
		# @param [String] task the task to add to the list
		def add task
			list = DATABASE[:Lists].select(:Total, :Id)[:Name=>Todo::Config[:working_list_name]]
			if !list
				DATABASE[:Lists] << {:Name => Config[:working_list_name], :Total => 0}
				list = DATABASE[:Lists].select(:Total, :Id)[:Name=>Todo::Config[:working_list_name]]
			end
			count = list[:Total]+1
			DATABASE[:Tasks] << {:Task_number => count, :Name => task, :Completed => 0}
			list_id = list[:Id]
			task_id = DATABASE[:Tasks][:Name=>task][:Id]
			DATABASE[:Task_list] << {:Task_id => task_id, :List_id => list_id}
			DATABASE[:Lists].filter(:Id => list_id).update(:Total => count)
		end

		# finish the task. task is either a case insensitive task on the list or
		# the task number. Prints out either the task is not in the list or that i
		# succesfully finished the task
		#
		# @param task either a task number or task name to finish
		# @param [Bool] is_num if the task param represents the task number, true. 
		# false if it is the task name
		def finish task, is_num
			finish_undo task, is_num, 0, 1
		end

		# undos finishing a task. task is either a case insensitive task on the list or
		# the task number. Prints out either the task is not in the list or that i
		# succesfully undoed finished the task
		#
		# @param task either a task number or task name to finish
		# @param [Bool] is_num if the task param represents the task number, true. 
		# false if it is the task name
		def undo task, is_num
			finish_undo task, is_num, 1, 0
		end

		# clears either just the completed or the uncompleted tasks
		#
		# @param completed [Integer] 1 if clearing completed tasks, 0 if clearing 
		# Uncompleted tasks
		def clear_each completed ,list_name
			#tasks = DATABASE.execute("SELECT Id from Tasks WHERE Id IN 
			#	(SELECT Task_ID FROM Task_list WHERE List_Id IN 
			#		(SELECT Id FROM Lists WHERE Name='"+list_name+"' AND Tasks.Completed ="+ completed.to_s+ "))")
			tasks = DATABASE[:Tasks].join(:Task_list, :Tasks__id => :Task_list__Task_id).join(
				:Lists, :Lists__id => :Task_list__List_id).select(:Tasks__Id).filter(
				:Lists__Name => Config[:working_list_name]).filter(:Tasks__Completed => completed)
			tasks.each do |task|
				DATABASE[:Task_list].filter(:Task_id => task[:Id]).delete
				DATABASE[:Tasks].filter(:Id => task[:Id]).delete
				#DATABASE.execute("DELETE FROM Task_list WHERE Task_id=" + task[0].to_s)
				#DATABASE.execute("DELETE FROM Tasks WHERE Id=" + task[0].to_s)
			end
		end

		# clears all the tasks in the list 
		# 
		# @param [Bool] clear_all if true, clears all completed and uncompleted tasks
		# and resets the count. if false, just clears the completed tasks
		def clear clear_all, list_name = Config[:working_list_name]
			clear_each 1, list_name
			if clear_all
				clear_each 0, list_name
				DATABASE[:Lists].filter(:Name => list_name).update(:Total => 0)
				DATABASE[:Lists].filter(:Name => list_name).delete
				#DATABASE.execute("UPDATE Lists SET Total = 0 WHERE Name = '" + list_name +"'")
				#DATABASE.execute("DELETE FROM Lists WHERE Name = '" + list_name +  "'")
				puts "Cleared all tasks in #{list_name}"
			else
				puts "Cleared completed tasks in #{Config[:working_list_name]}"
			end
		end

		# Helper method for finishing and undoing a task
		# 
		# @param task either a task number or task name to finish
		# @param [Bool] is_num if the task param represents the task number, true. 
		# false if it is the task name
		# @param initial [Integer] 0 if you are finishing a task, 1 if you are undoing a task
		# @param final [Integer] 1 if you are finishing a task, 0 if you ara undoing a task
		def finish_undo task , is_num, initial, final
			list_id = DATABASE[:Lists][:Name => Config[:working_list_name]][:Id]
			names =DATABASE[:Tasks].join(:Task_list, :Tasks__Id => :Task_list__Task_Id).join(
				:Lists, :Lists__Id => :Task_list__List_id).select(:Tasks__Id, :Tasks__Task_number, :Tasks__Name).filter(:Lists__Name => 
				Config[:working_list_name]).filter(:Tasks__Completed => initial)
			if is_num
				found_task = names[:Task_number => task]
				if found_task
					DATABASE[:Tasks].filter(:Id => found_task[:Id]).update(:Completed => final)
				else
					puts "Task ##{task} is not in the list."
				end
			else
				found_task = names[:Tasks__Name.downcase => task.downcase]
				if found_task
					DATABASE[:Tasks].filter(:Id => found_task[:Id]).update(:Completed => final)
				else
					puts "Task '#{task}' is not in the list."
				end
			end
		end
	end	
end
