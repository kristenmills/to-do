require 'sequel'
require 'sequel/extensions/migration'
require File.join(File.dirname(__FILE__), 'to-do', 'config')
require File.join(File.dirname(__FILE__), 'to-do', 'old', 'list')
if !File.exists?(File.join(ENV['HOME'], '.to-do'))
	Dir.mkdir(File.join(ENV['HOME'], '.to-do'))
	Todo::Config.write
end

database = Sequel.sqlite Todo::Config[:task_database]

# Migrate the database to the latest version
Sequel::Migrator.apply(database, File.join(File.dirname(__FILE__),'to-do', 'dbmigrations'))

# If a lists file exists from back when we were using YAML populate the database with that information
if File.exists?(File.join(ENV['HOME'], '.to-do', 'lists')) && database[:Lists].empty?
	add_tasks = Proc.new { |list_object, list_id, completed| 
		list_object.completed_tasks.each do |num, task|
			database[:Tasks].insert(:Task_number => num.to_s, :Name => task, :Completed => completed)
			task_id = database[:Tasks].count
			database[:Task_list].insert(:Task_id => task_id, :List_id => list_id)
		end
	}
	Dir.chdir(File.join(ENV['HOME'], '.to-do', 'lists')) do 
		lists = Dir.entries "."
		lists.each do |file|
			next if file == "." or file == ".."
			list_object = YAML.load_file(file)
			database[:Lists].insert(:Name => list_object.name, :Total => list_object.count)
			list_id = database[:Lists].count
			add_tasks.call list_object, list_id, 0
			add_tasks.call list_object, list_id, 1
		end
	end
end

require File.join(File.dirname(__FILE__), 'to-do', 'helpers', 'helpers') 
require File.join(File.dirname(__FILE__), 'to-do', 'tasks')
require File.join(File.dirname(__FILE__), 'to-do', 'cli')


# Todo is the main namespace that all of the other modules and classes are a 
# part of
module Todo
end