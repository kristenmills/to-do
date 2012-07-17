require 'optparse'
require 'yaml'
require 'colorize'
require 'sqlite3'

module Todo 
	# CLI is the module that contains the methods to display the list as well as
	# the methods to parse command line arguments.
	module CLI 
		extend self

		# The database
		DATABASE = SQLite3::Database.new(Todo::Config[:task_database])
		# The current working list
		#WORKING_LIST=YAML.load_file(File.join(Config[:lists_directory], 
		#	Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
		#	Config[:working_list_name]+'.yml'))

		# The option flags 
		OPTIONS = {
			:is_num => false, 
			:clear_all => false
		}

		# Displays the list in a human readable form:
		#
		# @example 
		#     ********************************
		#               List name
		#     ********************************
		# 
		#      Todo:
		#         1. Task 1
		#         2. Task 2
		#
		#      Completed:                  2/4
		#        3. Task 3
		#        4. Task 4
		#
		# @param [List] list the list you want to display.
		def display list = []
			tasks = DATABASE.execute "SELECT Task_number, Name, Completed FROM Tasks WHERE Id IN 
				(SELECT Task_id FROM Task_list WHERE List_id IN 
				(SELECT Id FROM Lists Where Lists.Name='" + Config[:working_list_name]+"'))"
			count = DATABASE.execute("SELECT Total FROM Lists WHERE Name = '" + Config[:working_list_name] + "'")[0][0]
			#count = !list ? list[0][0] : 0
			completed_count = 0
			puts "********************************".colorize(:light_red)
			puts Config[:working_list_name].center(32).colorize(:light_cyan)
			puts "********************************".colorize(:light_red)
			puts
			puts "Todo:".colorize(:light_green)
			tasks.each do |task|
				if task[2] == 0
					completed_count +=1
					next
				end
				printf "%4d. ".to_s.colorize(:light_yellow), task[0]
				puts task[1]
			end
			print "\nCompleted:".colorize(:light_green)
			printf "%36s\n", "#{completed_count}/#{count}".colorize(:light_cyan)
			tasks.each do |task|
				next if task[2] == 1
				printf "%4d. ".to_s.colorize(:light_yellow), task[0]
				puts task[1]
			end
			puts
		end

		# Helper method for parsing the options using OptionParser
		def option_parser
			OptionParser.new do |opts|
				version_path = File.expand_path("../../VERSION", File.dirname(__FILE__))
				opts.version = File.exist?(version_path) ? File.read(version_path) : ""
				opts.banner = "Usage: todo [COMMAND] [option] [arguments]"
				opts.separator "Commands:"
				opts.separator "    <blank>, display, d              displays the current list"
				opts.separator "    add, a <task>                    adds the task to the current list"
				opts.separator "    finish, f [option] <task>        marks the task as completed"
				opts.separator "    clear [option]                   clears completed tasks"
				opts.separator "    undo, u [option] <task>          undos a completed task"
				opts.separator "    create, switch <list name>       creates a new list or switches to an existing one"
				opts.separator "    remove, rm <list name>           removes the list completely (cannot undo)"
				opts.separator "Options: "
				opts.on('-n', 'with finish or undo, references a task by its number') do
					OPTIONS[:is_num] = true
				end
				opts.on('-a', 'with clear, resets the entire list') do
					OPTIONS[:clear_all] = true
				end
				opts.on('-h', '--help', 'displays this screen' ) do
					puts opts
					exit
				end
				opts.on('-w', "displays the name of the current list") do
					if Config[:working_list_exists]
						puts "Working list is #{WORKING_LIST.name}"
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
					exit
				end
			end
		end

		# Helper method for parsing commands.
		def commands_parser
			if ARGV.count > 0
				case ARGV[0]
				when "add", "a"
					if Config[:working_list_exists]
						ARGV.count > 1 ? Tasks.add(ARGV[1..-1].join(' ')) : puts("Usage: todo add <task name>")
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "finish", "f"
					if Config[:working_list_exists]
						WORKING_LIST.finish ARGV[1..-1].join(' '), OPTIONS[:is_num]
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "clear"
					if Config[:working_list_exists]
						WORKING_LIST.clear OPTIONS[:clear_all]
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "display", "d"
					if Config[:working_list_exists]
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "create", "switch"
					if ARGV.count > 0
						Config[:working_list_name] = ARGV[1..-1].join(' ')
						Config[:working_list_exists] = true
						puts "Switch to #{ARGV[1..-1].join(' ')}"
						display
					else
						puts "Usage: todo #{ARGV[0]} <listname>"
					end			
					# if File.exists?(File.join(Config[:lists_directory], ARGV[1..-1].join('_').downcase + '.yml'))
					# 	Config[:working_list_name] = ARGV[1..-1].join('_').downcase
					# 	Config[:working_list_exists] = true
					# 	puts "Switch to #{ARGV[1..-1].join(' ')}"
					# 	new_list = YAML.load_file(File.join(Config[:lists_directory], 
					# 	Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
					# 	Config[:working_list_name]+'.yml'))
					# 	display new_list
					# else 
					# 	ARGV.count > 1 ? List.new(ARGV[1..-1].join(' ')) : puts("Usage: todo create <list_name> ")
					# 	new_list = YAML.load_file(File.join(Config[:lists_directory], 
					# 	Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
					# 	Config[:working_list_name]+'.yml'))
					# 	display new_list
					# end
				when "undo", "u"
					if Config[:working_list_exists]
						WORKING_LIST.undo ARGV[1..-1].join(' '), OPTIONS[:is_num]
					display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "remove", "r"
					if ARGV.count > 1
						List.remove ARGV[1..-1].join(' ')
					end
				else
					puts "Invalid command.  See todo -h for help."
				end
			else
				if Config[:working_list_exists]
					display 
				else
					puts "Working List does not exist yet.  Please create one"
					puts "todo create <list name>"
				end
			end
		end

		# Parses the commands and options
		def parse
			optparse = option_parser
			begin
				optparse.parse!
				commands_parser
			rescue OptionParser::InvalidOption => e
				puts "#{e}. See todo -h for help."
			end
		end

	end
end
