module Todo

	# The module that contains methods for manipulating the database
	module Tasks
		extend self

		# Adds the tast to the list
		# 
		# @param [String] task the task to add to the list
		# @param [Integer] priority the priority of the task
		def add task, priority=1
			list = Helpers::DATABASE[:Lists].select(:Total, :Id)[:Name=>Todo::Config[:working_list_name]]
			if !list
				Helpers::DATABASE[:Lists] << {:Name => Config[:working_list_name], :Total => 0}
				list = Helpers::DATABASE[:Lists].select(:Total, :Id)[:Name=>Todo::Config[:working_list_name]]
			end
			count = list[:Total]+1
			Helpers::DATABASE[:Tasks] << {:Task_number => count, :Name => task, :Completed => 0, :Priority => priority}
			list_id = list[:Id]
			task_id = Helpers::DATABASE[:Tasks].with_sql("SELECT last_insert_rowid() FROM Tasks")
			Helpers::DATABASE[:Task_list] << {:Task_id => task_id, :List_id => list_id}
			Helpers::DATABASE[:Lists].filter(:Id => list_id).update(:Total => count)
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
			tasks = Helpers::DATABASE[:Tasks].join(:Task_list, :Tasks__id => :Task_list__Task_id).join(
				:Lists, :Lists__id => :Task_list__List_id).select(:Tasks__Id).filter(
				:Lists__Name => Config[:working_list_name]).filter(:Tasks__Completed => completed)
			tasks.each do |task|
				Helpers::DATABASE[:Task_list].filter(:Task_id => task[:Id]).delete
				Helpers::DATABASE[:Tasks].filter(:Id => task[:Id]).delete
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
				#Helpers::DATABASE[:Lists].filter(:Name => list_name).update(:Total => 0)
				Helpers::DATABASE[:Lists].filter(:Name => list_name).delete
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
			list_id = Helpers::DATABASE[:Lists][:Name => Config[:working_list_name]][:Id]
			names =Helpers::DATABASE[:Tasks].join(:Task_list, :Tasks__Id => :Task_list__Task_Id).join(
				:Lists, :Lists__Id => :Task_list__List_id).select(:Tasks__Id, :Tasks__Task_number, 
				:Tasks__Name).filter(:Lists__Name => Config[:working_list_name]).filter(
				:Tasks__Completed => initial)
			Helpers::Tasks::update_task is_num, names, task, :Completed, final
		end

		# Sets the priority of a task
		# 
		# @param priority [Integer] the new priority
		# @param tasks either a task number or a task name to change the priority of 
		# @param [Bool] is_num if the task param represents the task number, true. 
		# false if it is the task name
		def set_priority priority, task, is_num
			list_id = Helpers::DATABASE[:Lists][:Name => Config[:working_list_name]][:Id]
			names =Helpers::DATABASE[:Tasks].join(:Task_list, :Tasks__Id => :Task_list__Task_Id).join(
				:Lists, :Lists__Id => :Task_list__List_id).select(:Tasks__Id, :Tasks__Task_number, 
				:Tasks__Name).filter(:Lists__Name => Config[:working_list_name])
			Helpers::Tasks::update_task is_num, names, task, :Priority, priority
		end
	end	
end
