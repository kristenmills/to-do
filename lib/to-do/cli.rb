require 'optparse'
require 'yaml'
require 'colorize'

module Todo 
	# CLI is the module that contains the methods to display the list as well as
	# the methods to parse command line arguments.
	module CLI 
		extend self

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
			tasks = Helpers.task_names
			tasks = Helpers::CLI::OPTIONS[:sort] == "n" ? tasks.order(:Task_number) : tasks.order(:Priority, :Task_number)
			list = Helpers::DATABASE[:Lists][:Name=>Config[:working_list_name]]
			count = list.nil? ? 0 : list[:Total]
			completed_count = tasks.filter(:Completed=>1).count

			#print out the header
			Helpers::CLI.print_header
			
			puts
			puts

			#prints out incomplete tasks
			puts "Todo:".colorize(:light_green)
			Helpers::CLI.print_tasks 1, tasks

			#Prints out complete tasks
			print "\nCompleted:".colorize(:light_green)
			printf "%#{Config[:width]+4}s\n", "#{completed_count}/#{count}".colorize(:light_cyan)
			Helpers::CLI.print_tasks 0, tasks
			puts
		end

		# Helper method for parsing the options using OptionParser
		def option_parser
			OptionParser.new do |opts|
				Helpers::CLI.options_title opts
				Helpers::CLI.options_create opts
				Helpers::CLI.options_display opts
				Helpers::CLI.options_add opts
				Helpers::CLI.options_finish opts
				Helpers::CLI.options_undo opts
				Helpers::CLI.options_clear opts
				Helpers::CLI.options_remove opts
				Helpers::CLI.options_set opts
				Helpers::CLI.options_other opts
			end
		end

		# Helper method for parsing commands.
		def commands_parser
			if ARGV.count > 0
				should_display = false
				if ARGV.count > 1 
					should_display =  true

					case ARGV[0]
					when "create", "switch"
							name = ARGV[1..-1].map{|word| word.capitalize}.join(' ')
							Config[:working_list_name] =  name
							Config[:working_list_exists] = true
							puts "Switch to #{name}"
					when "add", "a"
						Tasks.add(ARGV[1..-1].join(' '), Helpers::CLI::OPTIONS[:priority]) 
					when "finish", "f"
						Tasks.finish(ARGV[1..-1].join(' '), Helpers::CLI::OPTIONS[:is_num])
					when "undo", "u"
						Tasks.undo(ARGV[1..-1].join(' '), Helpers::CLI::OPTIONS[:is_num])
					when "clear"
						Tasks.clear Helpers::CLI::OPTIONS[:clear_all]
					when "remove", "r"
						Tasks.clear true, ARGV[1..-1].map{|word| word.capitalize}.join(' ')
						should_display = false
					when "set", "s"
						if Helpers::CLI::OPTIONS[:change_priority]
							Tasks.set_priority Helpers::CLI::OPTIONS[:priority], ARGV[1..-1].join(' '), OPTIONS[:is_num]
						end
					else
						puts "Invalid command.  See todo -h for help."
						should_display = false
					end
				end
				if ARGV[0] == "display" || ARGV[0] == "d" || should_display
					puts
					display
				elsif Helpers::CLI::USAGE[ARGV[0].to_sym].nil?
					puts "Invalid command.  See todo -h for help."
				elsif ARGV.count < 1
					puts "Usage: #{Helpers::CLI::USAGE[ARGV[0].to_sym]}"
				end
			else
				display
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
	end
end