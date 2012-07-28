require 'optparse'
require 'yaml'
require 'colorize'

module Todo 
	# CLI is the module that contains the methods to display the list as well as
	# the methods to parse command line arguments.
	module CLI 
		extend self

		# The database
		DATABASE = Sequel.sqlite Todo::Config[:task_database]

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
		def display
			tasks = DATABASE[:Tasks].join(:Task_list, :Tasks__id => :Task_list__Task_id).join(
				:Lists, :Lists__id => :Task_list__List_id).select(:Tasks__Task_number, :Tasks__Name, 
				:Tasks__Completed).filter(:Lists__Name => Config[:working_list_name])
			tasks = tasks.order(:Task_number)
			list = DATABASE[:Lists][:Name=>Config[:working_list_name]]
			count = list.nil? ? 0 : list[:Total]
			completed_count = tasks.filter(:Completed=>1).count
			Config[:width].times do 
				print "*".colorize(:light_red)
			end
			puts
			split_name = split Config[:working_list_name], Config[:width]
			split_name.each do |line|
				puts line.center(Config[:width]).colorize(:light_cyan)
			end
			Config[:width].times do 
				print "*".colorize(:light_red)
			end
			puts
			puts
			puts "Todo:".colorize(:light_green)
			tasks.each do |task|
				next if task[:Completed] == 1
				printf "%4d. ".to_s.colorize(:light_yellow), task[:Task_number] 
				split_v = split task[:Name], Config[:width] - 6
				puts split_v[0]
				split_v.shift
				split_v.each do |line|
					printf "      %s\n", line
				end
			end
			print "\nCompleted:".colorize(:light_green)
			printf "%#{Config[:width]+4}s\n", "#{completed_count}/#{count}".colorize(:light_cyan)
			tasks.each do |task|
				next if task[:Completed] == 0
				printf "%4d. ".to_s.colorize(:light_yellow), task[:Task_number]
				split_v = split task[:Name], Config[:width]-6
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
				opts.banner = "Todo: A simple command line todo application\n\n" +
				"    Usage: todo [COMMAND] [option] [arguments]"
				opts.separator ""
				opts.separator "Commands:"
				opts.separator "  * create, switch - creates a new list or switches to an existing one"
				opts.separator "    usage: todo create <LIST NAME>"
				opts.separator ""
				opts.separator "  * display, d - displays the current list"
				opts.separator "    usage: todo [display] [-s {p,n}]"

				opts.on('-s TYPE', [:p, :n], "sorts the task by ") do |s|

				end

				opts.separator ""
				opts.separator "  * add, a - adds the task to the current list"
				opts.separator "    usage: todo add [-p {high, medium, low}] <TASK>"

				opts.on('-p PRIORITY', [:high, :medium, :low], 'set the priority of the task to one of the following. Default is medium') do |p|

				end

				opts.separator ""
				opts.separator "  * finish , f -  marks a task as finished"
				opts.separator "    usage: todo finish [-n] <TASK>"

				opts.on('-n', 'references a task by its number') do
					OPTIONS[:is_num] = true
				end

				opts.separator ""
				opts.separator "  * undo, u - undos a completed task"
				opts.separator "    usage: todo undo [-n] <TASK>"
				opts.separator "    -n                               references a task by its number"
				opts.separator ""
				opts.separator "  * clear - clears a completed tasks"
				opts.separator "    usage: todo clear [-a]"

				opts.on('-a', 'resets the entire list') do
					OPTIONS[:clear_all] = true
				end

				opts.separator "" 
				opts.separator "  * remove, rm - removes the list completely."
				opts.separator "    usage: todo remove <LIST NAME> "
				opts.separator ""
				opts.separator "Other Options: "

				opts.on('-h', '--help', 'displays this screen' ) do
					puts opts
					exit
				end
				opts.on('-w', "displays the name of the current list") do
					if Config[:working_list_exists]
						puts "Working list is #{Config[:working_list_name]}"
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
				when "display", "d"
					if Config[:working_list_exists]
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "create", "switch"
					if ARGV.count > 0
						name = ARGV[1..-1].map{|word| word.capitalize}.join(' ')
						Config[:working_list_name] =  name
						Config[:working_list_exists] = true
						puts "Switch to #{name}"
						puts
						display
					else
						puts "Usage: todo #{ARGV[0]} <listname>"
					end		
				when "add", "a"
					if Config[:working_list_exists]
						ARGV.count > 1 ? Tasks.add(ARGV[1..-1].join(' ')) : puts("Usage: todo add <task name>")
						puts
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "finish", "f"
					if Config[:working_list_exists]
						ARGV.count > 1 ? Tasks.finish(ARGV[1..-1].join(' '), OPTIONS[:is_num]) : puts("Usage: todo finish <task name>")
						puts
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "undo", "u"
					if Config[:working_list_exists]
						ARGV.count > 1 ? Tasks.undo(ARGV[1..-1].join(' '), OPTIONS[:is_num]) : puts("Usage: todo undo <task name>")
						puts
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end
				when "clear"
					if Config[:working_list_exists]
						Tasks.clear OPTIONS[:clear_all]
						puts
						display
					else
						puts "Working List does not exist yet.  Please create one"
						puts "todo create <list name>"
					end	
				when "remove", "r"
					if ARGV.count > 1
						Tasks.clear true, ARGV[1..-1].map{|word| word.capitalize}.join(' ')
					else 
						puts "Usage todo remove <list name>"
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