require 'optparse'
require 'yaml'
require 'colorize'

module Todo 
	# CLI is the module that contains the methods to display the list as well as
	# the methods to parse command line arguments.
	module CLI 
		extend self
			# The current working list
			WORKING_LIST=YAML.load_file(File.join(Config[:lists_directory], Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], Config[:working_list_name]+'.yml'))

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
		def display list = WORKING_LIST
			Config[:width].times do 
				print "*".colorize(:light_red)
			end
			puts 
			split_name = split list.name, Config[:width]
			split_name.each do |line|
				puts line.center(Config[:width]).colorize(:light_cyan)
			end
			Config[:width].times do 
				print "*".colorize(:light_red)
			end
			puts 
			puts
			puts "Todo:".colorize(:light_green)
			list.tasks.each do |k,v|
				printf "%4d. ".to_s.colorize(:light_yellow), k
				split_v = split v, Config[:width] - 6
				puts split_v[0]
				split_v.shift
				split_v.each do |line|
					printf "      %s\n", line
				end
			end
			print "\nCompleted:".colorize(:light_green)
			printf "%#{Config[:width]+4}s\n", "#{list.completed_count}/#{list.count}".colorize(:light_cyan)
			list.completed_tasks.each do |k,v|
				printf "%4d. ".to_s.colorize(:light_yellow), k
				split_v = split v, Config[:width]-6
				puts split_v[0]
				split_v.shift
				split_v.each do |line|
					printf "      %s\n", line
				end
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
						ARGV.count > 1 ? WORKING_LIST.add(ARGV[1..-1].join(' ')) : puts("Usage: todo add <task name>")
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
					if File.exists?(File.join(Config[:lists_directory], ARGV[1..-1].join('_').downcase + '.yml'))
						Config[:working_list_name] = ARGV[1..-1].join('_').downcase
						Config[:working_list_exists] = true
						puts "Switch to #{ARGV[1..-1].join(' ')}"
						new_list = YAML.load_file(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml'))
						display new_list
					else 
						ARGV.count > 1 ? List.new(ARGV[1..-1].join(' ')) : puts("Usage: todo create <list_name> ")
						new_list = YAML.load_file(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml'))
						display new_list
					end
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

		# splits string for wrapping
		def split string, width
			split = Array.new
			if string.length > width #if the string needs to be split
				string_words = string.split(" ")
				line = ""
				string_words.each do |x|
					if x.length > width #if the word needs to be split
						#add the start of the word onto the first line (even if it has already started)
						while line.length < width
							line += x[0]
							x = x[1..-1]
						end
						split << line
						#split the rest of the word up onto new lines
						split_word = x.scan(%r[.{1,#{width}}])
						split_word[0..-2].each do |word|
							split << word
						end
						line = split_word.last+" "
					elsif (line + x).length > width-1 #if the word would fit alone on its own line
						split << line.chomp
						line = x
					else #if the word can be added to this line
						line += x + " "
					end
				end
				split << line
			else #if the string doesn't need to be split
				split = [string]
			end
			#give back the split line
			return split
		end

	end
end
