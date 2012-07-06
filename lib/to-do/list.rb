require 'yaml'
require File.join(File.dirname(__FILE__), 'config')

module Todo
	class List
		attr_accessor :tasks, :completed_tasks, :count, :completed_count, :name

		#Create a new list
		def initialize name
			@tasks = Hash.new 
			@completed_tasks = Hash.new
			@count = 0
			@completed_count = 0
			@name = name
			if !File.exists? Config['lists_directory']
				Dir.mkdir(Config['lists_directory'])
			end
			update
      Config['working_list_name'] = name.downcase.gsub(/ /, '_')
      Config.write
		end

		# updates the yaml
		def update 
			path = File.join(Config['lists_directory'], @name.downcase.gsub(/ /, '_') +'.yml')
			File.open(path, 'w') do |fh|
        fh.puts(self.to_yaml)
      end
    end

    # adds the tast to the list
		def add task
			@count+=1
			@tasks[@count] = task
			puts "Added task #{task}"
			update
		end

		# finish the task. task is either a case insensitive task on the list or 
		# the task number
		def finish task, is_num
			if is_num
				if !@tasks[task.to_i].nil?
					@completed_tasks[task.to_i] = @tasks[task.to_i]
					@tasks.delete(task.to_i)
					@completed_count+=1
					puts "Finished #{@completed_tasks[task.to_i]}."
				else
					puts "Task #{task} not in list"
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
					puts "Finished #{@completed_tasks[num]}."
				else
					puts "Task #{task} is not in list"
				end 
			end
			update
		end

		#clears the completed tasks
		def clear_completed
			@completed_tasks = Hash.new
			update
		end

		#clears all of the tasks and resets the count to 0
		def clear clear_all
			clear_completed
			if clear_all 
				@tasks = Hash.new
				@completed_count = 0
				@count = 0
			end
			update
		end
	end
end

