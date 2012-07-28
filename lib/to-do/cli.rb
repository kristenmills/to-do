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
			:clear_all => false,
			:priority => "medium", 
			:sort => "n"
		}

		# Usage messages for each of the commnands
		USAGE = {
			:default => "todo [COMMAND] [option] [arguments]", 
			:create  => "todo create|switch <LIST NAME>", 
			:display => "todo [display|d] [-s {p,n}]",
			:add => "todo add|a [-p {high, medium, low}] <TASK>", 
			:finish => "todo finish|f [-n <TASK_NUMBER>] [<TASK>]",
			:undo => "todo undo|u [-n <TASK_NUMBER>] [<TASK>]",
			:clear => "todo clear [-a]",
			:remove => "todo remove|rm <LIST NAME>",
			:set => "todo set|s [-p {high, medium, low}] [-n <TASK_NUMBER>] [<TASK>]"
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
				:Tasks__Completed, :Tasks__Priority).filter(:Lists__Name => Config[:working_list_name])
			tasks = OPTIONS[:sort] == "n" ? tasks.order(:Task_number) : tasks.order(:Priority, :Task_number)
			list = DATABASE[:Lists][:Name=>Config[:working_list_name]]
			count = list.nil? ? 0 : list[:Total]
			completed_count = tasks.filter(:Completed=>1).count

			priority = {
				0 => "**",
				1 => "*",
				2 => ""
			}
			#print out the header
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

			#prints out incomplete tasks
			puts "Todo:".colorize(:light_green)
			tasks.each do |task|
				next if task[:Completed] == 1
				printf "%2s".colorize(:light_magenta), priority[task[:Priority]]
				printf "%3d. ".colorize(:light_yellow), task[:Task_number] 
				split_v = split task[:Name], Config[:width] - 7
				puts split_v[0]
				split_v.shift
				split_v.each do |line|
					printf "      %s\n", line
				end
			end

			#Prints out complete tasks
			print "\nCompleted:".colorize(:light_green)
			printf "%#{Config[:width]+4}s\n", "#{completed_count}/#{count}".colorize(:light_cyan)
			tasks.each do |task|
				next if task[:Completed] == 0
				printf "%2s".colorize(:light_magenta), priority[task[:Priority]]
				printf "%3d. ".to_s.colorize(:light_yellow), task[:Task_number]
				split_v = split task[:Name], Config[:width]-7
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
				opts.banner = "Todo: A simple command line todo application\n\n".colorize(:light_green) +
				"    usage:".colorize(:light_cyan) + " todo [COMMAND] [option] [arguments]".colorize(:light_red)
				opts.separator ""
				opts.separator "Commands:".colorize(:light_green)

				#todo create, switch
				opts.separator "  *".colorize(:light_cyan)  + " create, switch".colorize(:light_yellow) +  " creates a new list or switches to an existing one".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:create].colorize(:light_red)
				
				# todo display, d
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " display, d".colorize(:light_yellow) +  " displays the current list".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:display].colorize(:light_red)
				opts.on('-s TYPE', [:p, :n], "sorts the task by ") do |s|
					OPTIONS[:sort] = s
				end

				#todo add, a
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " add, a".colorize(:light_yellow) +  " adds the task to the current list".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:add].colorize(:light_red)
				opts.on('-p PRIORITY', ["high", "medium", "low"], 'set the priority of the task to one of the following.\n' + 
				'                                                    Default is medium') do |p|
					priorities = {
						"high" => 0,
						"medium" => 1,
						"low" => 2
					}

					OPTIONS[:priority] = priorities[p]
				end

				#todo finish, f
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " finish , f".colorize(:light_yellow) +  " marks a task as finished".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:finish].colorize(:light_red)
				opts.on('-n',  'references a task by its number') do |n|
					OPTIONS[:is_num] = true
				end

				#todo undo, u
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " undo, u".colorize(:light_yellow) +  " undos a completed task".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:undo].colorize(:light_red)
				opts.separator "    -n                               references a task by its number"

				#todo clear
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " clear".colorize(:light_yellow) +  " clears a completed tasks".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:clear].colorize(:light_red)
				opts.on('-a', 'resets the entire list') do
					OPTIONS[:clear_all] = true
				end

				#todo remove, rm
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " remove, rm".colorize(:light_yellow) +  " removes the list completely.".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:remove].colorize(:light_red)

				#todo set, s
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan) + " set, s".colorize(:light_yellow) + " adds additional information to a task".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:set].colorize(:light_red)
				opts.separator "    -p TYPE                          set the priority of the task to one of the following.\n" + 
				"                                     Default is medium"
				opts.separator "    -n                               references a task by its number"

				opts.separator ""
				opts.separator "Other Options: ".colorize(:light_green)

				#todo -h
				opts.on('-h', '--help', 'displays this screen' ) do
					puts opts
					exit
				end
				#todo -w
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
						puts "Usage: #{USAGE[:create]}"
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
						puts "Usage: #{USAGE[:create]}"
					end		
				when "add", "a"
					if Config[:working_list_exists]
						ARGV.count > 1 ? Tasks.add(ARGV[1..-1].join(' '), OPTIONS[:priority]) : puts("Usage: #{USAGE[:add]}")
						puts
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "Usage: #{USAGE[:create]}"
					end
				when "finish", "f"
					if Config[:working_list_exists]
						ARGV.count > 1 ? Tasks.finish(ARGV[1..-1].join(' '), OPTIONS[:is_num]) : puts("Usage: #{USAGE[:finish]}")
						puts
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "Usage: #{USAGE[:create]}"
					end
				when "undo", "u"
					if Config[:working_list_exists]
						ARGV.count > 1 ? Tasks.undo(ARGV[1..-1].join(' '), OPTIONS[:is_num]) : puts("Usage: #{USAGE[:undo]}")
						puts
						display 
					else
						puts "Working List does not exist yet.  Please create one"
						puts "Usage: #{USAGE[:create]}"
					end
				when "clear"
					if Config[:working_list_exists]
						Tasks.clear OPTIONS[:clear_all]
						puts
						display
					else
						puts "Working List does not exist yet.  Please create one"
						puts "Usage: #{USAGE[:create]}"
					end	
				when "remove", "r"
					if ARGV.count > 1
						Tasks.clear true, ARGV[1..-1].map{|word| word.capitalize}.join(' ')
					else 
						puts "Usage: #{USAGE[:remove]}"
					end
				else
					puts "Invalid command.  See todo -h for help."
				end
			else
				if Config[:working_list_exists]
					display 
				else
					puts "Working List does not exist yet.  Please create one"
					puts "Usage: #{USAGE[:create]}"
				end
			end
		end

		# Parses the commands and options
		def parse
			optparse = option_parser
			begin
				optparse.parse!
				commands_parser
			rescue OptionParser::InvalidOption, OptionParser::InvalidArgument => e
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