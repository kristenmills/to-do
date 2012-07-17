require 'sqlite3'
require File.join(File.dirname(__FILE__), 'to-do', 'config')
require File.join(File.dirname(__FILE__), 'to-do', 'list')

if !File.exists?(File.join(ENV['HOME'], '.to-do'))
	Dir.mkdir(File.join(ENV['HOME'], '.to-do'))
	Todo::Config.write
	#Dir.mkdir(Todo::Config[:lists_directory])
end

# If the Database doesn't exist, create it
if !File.exists?(Todo::Config[:task_database])
	Todo::Config.write
	database = SQLite3::Database.new(Todo::Config[:task_database])
	database.execute "CREATE TABLE Tasks(Id INTEGER PRIMARY KEY, Task_number INTEGER, Name TEXT, Completed INTEGER)"
	database.execute "CREATE TABLE Lists(Id INTEGER PRIMARY KEY, Name TEXT, Total INTEGER)"
	database.execute "CREATE TABLE Task_list(Task_id INTEGER, List_id INTEGER)"

	# If you have existing lists from earlier versions stored in YAML, stick them 
	# in the sqlite database
	if File.exists?(File.join(ENV['HOME'], '.to-do', 'lists'))
		Dir.chdir(File.join(ENV['HOME'], '.to-do', 'lists')) do 
			lists = Dir.entries "."
			lists.each do |file|
				next if file == "." or file == ".."
				list_object = YAML.load_file(file)
				database.execute "INSERT INTO Lists (Name, Total) VALUES('" + list_object.name + "', " + list_object.count.to_s + ")"
				list_id = database.last_insert_row_id
				list_object.tasks.each do |num, task|
					database.execute "INSERT INTO Tasks (Task_number, Name, Completed) VALUES('" + num.to_s + "', '" + task + "', 0)"
					task_id = database.last_insert_row_id 
					database.execute "INSERT INTO Task_list VALUES(" + task_id.to_s + ", " + list_id.to_s + ")"
				end
				list_object.completed_tasks.each do |num, task|
					database.execute "INSERT INTO Tasks (Task_number, Name, Completed) VALUES('" + num.to_s + "', '" + task + "', 1)"
					task_id = database.last_insert_row_id 
					database.execute "INSERT INTO Task_list VALUES(" + task_id.to_s + ", " + list_id.to_s + ")"
				end
			end
		end
	end
end
require File.join(File.dirname(__FILE__), 'to-do', 'cli')

# Todo is the main namespace that all of the other modules and classes are a 
# part of
module Todo
end