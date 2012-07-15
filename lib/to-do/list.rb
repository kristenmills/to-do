require 'yaml'
require File.join(File.dirname(__FILE__), 'config')
require 'fileutils'
module Todo

	# The Class that represents a list of tasks
	class List
		attr_accessor :tasks, :completed_tasks, :count, :completed_count, :name

		# Creates a new list and sets it to be the working list
		# 
		# @param [String] name the name of the list
		def initialize name
			@tasks = Hash.new
			@completed_tasks = Hash.new
			@count = 0
			@completed_count = 0
			@name = name
			if !File.exists? Config[:lists_directory]
				Dir.mkdir(Config[:lists_directory])
			end
			update
			Config[:working_list_name] = name.downcase.gsub(/ /, '_')
			Config[:working_list_exists] = true
			Config.write
			puts "Created List #{name}."
		end

		# Updates the yaml file
		def update
			path = File.join(Config[:lists_directory], @name.downcase.gsub(/ /, '_') +'.yml')
			File.open(path, 'w') do |fh|
				fh.puts(self.to_yaml)
			end
		end

		# Adds the tast to the list
		# 
		# @param [String] task the task to add to the list
		def add task
			@count+=1
			@tasks[@count] = task
			puts "Added task #{task}."
			update
		end

		# finish the task. task is either a case insensitive task on the list or
		# the task number. Prints out either the task is not in the list or that i
		# succesfully finished the task
		#
		# @param task either a task number or task name to finish
		# @param [Bool] is_num if the task param represents the task number, true. 
		# false if it is the task name
		def finish task, is_num
			if is_num
				if !@tasks[task.to_i].nil?
					@completed_tasks[task.to_i] = @tasks[task.to_i]
					@tasks.delete(task.to_i)
					@completed_count+=1
					@completed_tasks = Hash[@completed_tasks.sort]
					puts "Finished #{@completed_tasks[task.to_i]}."
				else
					puts "Task \##{task} not in list."
				end
			else
				hash = Hash.new
				@tasks.each do |k,v|
					hash[k] = v.downcase
				end
				if hash.value?(task.downcase)
					num = hash.key(task.downcase)
					@completed_tasks[num] = @tasks[num]
					@tasks.delete(num)
					@completed_count+=1
					@completed_tasks = Hash[@completed_tasks.sort]
					puts "Finished #{@completed_tasks[num]}."
				else
					puts "Task #{task} is not in list."
				end
			end
			update
		end

		# undos finishing a task. task is either a case insensitive task on the list or
		# the task number. Prints out either the task is not in the list or that i
		# succesfully undoed finished the task
		#
		# @param task either a task number or task name to finish
		# @param [Bool] is_num if the task param represents the task number, true. 
		# false if it is the task name
		def undo task, is_num
			if is_num
				if !@completed_tasks[task.to_i].nil?
					@tasks[task.to_i] = @completed_tasks[task.to_i]
					@completed_tasks.delete(task.to_i)
					@completed_count-=1
					@tasks = Hash[@tasks.sort]
					puts "Undo completeing #{@tasks[task.to_i]}."
				else
					puts "Task \##{task} not in list."
				end
			else
				hash = Hash.new
				@completed_tasks.each do |k,v|
					hash[k] = v.downcase
				end
				if hash.value?(task.downcase)
					num = hash.key(task.downcase)
					@tasks[num] = @completed_tasks[num]
					@completed_tasks.delete(num)
					@completed_count-=1
					@tasks = Hash[@tasks.sort]
					puts "Undo completeing #{@tasks[num]}."
				else
					puts "Task #{task} is not in list."
				end
			end
			update
		end

		# clears just the completed tasks
		def clear_completed
			@completed_tasks = Hash.new
			update
		end

		# clears the task in the list 
		# 
		# @param [Bool] clear_all if true, clears all completed and uncompleted tasks
		# and resets the count. if false, just clears the completed tasks
		def clear clear_all
			clear_completed
			if clear_all
				@tasks = Hash.new
				@completed_count = 0
				@count = 0
				puts "Cleared list."
			else
				puts "Cleared completed tasks."
			end
			update
		end

		# Class method that removes a list from the your lists.
		# 
		# @param [string] name name of the list that you are trying to remove
		def self.remove name
			underscore_name = name.downcase.gsub(/ /, '_')
			begin
				FileUtils.rm File.join(Config[:lists_directory], underscore_name +'.yml')
				puts "Removed list #{name}"
			rescue
				puts "List doesn't exist"
			end
			if underscore_name == Config[:working_list_name]
				Config[:working_list_exists] = false
			end
		end
	end
end

