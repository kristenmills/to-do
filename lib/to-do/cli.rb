require 'optparse'
require 'yaml'
require 'colorize'

module Todo 
	# CLI is the module that contains the methods to display the list as well as
	# the methods to parse command line arguments.
	module CLI 
		extend self
		if File.exists?(File.join(Config[:lists_directory], Config[:working_list_name]+'.yml'))
			# The current working list
			WORKING_LIST=YAML.load_file(File.join(Config[:lists_directory], Config[:working_list_name]+'.yml'))
		end

		# The option flags 
		OPTIONS = {
			:is_num => false, 
			:clear_all => false
		}

		#
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
		def display list = WORKING_LIST
			puts "********************************".colorize(:light_red)
			puts list.name.center(32).colorize(:light_cyan)
			puts "********************************".colorize(:light_red)
			puts
			puts "Todo:".colorize(:light_green)
			list.tasks.each do |k,v|
				printf "%4d. ".to_s.colorize(:light_yellow), k
				puts v
			end
			print "\nCompleted:".colorize(:light_green)
			printf "%36s\n", "#{list.completed_count}/#{list.count}".colorize(:light_cyan)
			list.completed_tasks.each do |k,v|
				printf "%4d. ".to_s.colorize(:light_yellow), k
				puts v
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
				opts.separator "    create, switch <list_name>       creates a new list or switches to an existing one"
				opts.separator "Options: "
				opts.on('-n', 'with finish or undo, references a task by its number') do
					OPTIONS[:is_num] = true
				end
				opts.on('-a', 'with clear, resets the entire list') do
					OPTIONS[:clear_all] = true
				end
				opts.on('-h', '--help', 'displays this screen' ) do
					puts opts
					return
				end
				opts.on('-w', "displays the name of the current list") do
					puts "Working list is #{WORKING_LIST.name}"
					return
				end
			end
		end

		# Helper method for parsing commands.
		def commands_parser
			if ARGV.count > 0
				case ARGV[0]
				when "add", "a"
					ARGV.count > 1 ? WORKING_LIST.add(ARGV[1..-1].join(' ')) : puts("Invalid Command")
					display 
				when "finish", "f"
					WORKING_LIST.finish ARGV[1..-1].join(' '), OPTIONS[:is_num]
					display 
				when "clear"
					WORKING_LIST.clear OPTIONS[:clear_all]
				when "display", "d"
					display 
				when "create", "switch"
					if File.exists?(File.join(Config[:lists_directory], ARGV[1..-1].join('_').downcase + '.yml'))
						Config[:working_list_name] = ARGV[1..-1].join('_').downcase
						puts "Switch to #{ARGV[1..-1].join(' ')}"
						new_list = YAML.load_file(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml'))
						display new_list
					else 
						ARGV.count > 1 ? List.new(ARGV[1..-1].join(' ')) : puts("Invalid Command")
						new_list = YAML.load_file(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml'))
						display new_list
					end
				when "undo", "u"
					WORKING_LIST.undo ARGV[1..-1].join(' '), OPTIONS[:is_num]
					display 
				else
					puts "Invalid Command"
				end
			else
				#if no ARGs are given, do what "display" would do
				display 
			end
		end

		# Parses the commands and options
		def parse
			optparse = option_parser
			optparse.parse!
			commands_parser
		end

	end
end
