require 'yaml'

$data = ENV["HOME"]+"/.todo/data.yml"
$settings = ENV["HOME"]+"/.todo/settings.yml"

module Todo
	module CLI

		def self.display 
			puts "To-do List:\n     "
		end

		def self.help
			puts <<EOF
todo - a simple command line todo application

Usage: 
	                     displays the current list
	add [task]           adds the task to the current todo list
	finish [task_number] moves the task to completed tasks
	-c [list]            shows the completed task
	-h, --help           displays help
EOF
		end

	end
end