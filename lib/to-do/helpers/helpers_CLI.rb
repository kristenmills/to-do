module Todo
	module Helpers

		# Helper methods used in the Todo::CLI module
		module CLI
			extend self

			# The option flags 
			OPTIONS = {
				:is_num => false, 
				:clear_all => false,
				:change_priority => false,
				:priority => 1, 
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
				:set => "todo set|s [-p {high, medium, low}] [-n <TASK_NUMBER>] [<TASK>]", 
				:config => "todo [--color-scheme {light, dark, none}] [--width <WIDTH_NUMBER>]"
			}

			# splits string for wrapping
			# 
			# @param [String] string the string to be split
			# @param [Width] width the width of the line
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
							line = x + " "
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

			#create a hash of the colors needed for display based on the config file
			def create_color_hash
				colors = [:black, :red, :green, :yellow, :blue, :magenta, :cyan, :white, :default]
				type = Config[:color]
				color_hash = Hash.new
				colors.each do |c|
					case type
					when "light"
						color_hash[c] = c
					when  "dark"
						color_hash[c] = ("light_" + c.to_s).to_sym
					else
						color_hash[c] = :default
					end
				end
				color_hash
			end

			# Helper method for the options parser that displays the title
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_title opts, colors
				version_path = File.expand_path("../../VERSION", File.dirname(__FILE__))
				opts.version = File.exist?(version_path) ? File.read(version_path) : ""
				opts.banner = "Todo: A simple command line todo application\n\n".colorize(colors[:green]) +
				"    usage:".colorize(colors[:cyan]) + " todo [COMMAND] [option] [arguments]".colorize(colors[:red])
				opts.separator ""
				opts.separator "Commands:".colorize(colors[:green])
			end

			# Helper method for the options parser for create, switch
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_create opts, colors
				#todo create, switch
				opts.separator "  *".colorize(colors[:cyan])  + " create, switch".colorize(colors[:yellow]) +  
				" creates a new list or switches to an existing one".colorize(colors[:magenta])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:create].colorize(colors[:red])
			end

			# Helper method for the options parser for display
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_display opts, colors
				opts.separator ""
				opts.separator "  *".colorize(colors[:cyan])  + " display, d".colorize(colors[:yellow]) +  
				" displays the current list".colorize(colors[:magenta])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:display].colorize(colors[:red])
				opts.on('-s TYPE', [:p, :n], "sorts the task by Type") do |s|
					OPTIONS[:sort] = s
				end
			end

			# Helper method for the options parser that for add
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_add opts, colors
				opts.separator ""
				opts.separator "  *".colorize(colors[:cyan])  + " add, a".colorize(colors[:yellow]) +  
				" adds the task to the current list".colorize(colors[:magenta])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:add].colorize(colors[:red])
				opts.on('-p PRIORITY', ["high", "medium", "low"], 'set the priority of the task to one of the', 'following. Default is medium') do |p|
					priorities = {
						"high" => 0,
						"medium" => 1,
						"low" => 2
					}
					OPTIONS[:change_priority] = true
					OPTIONS[:priority] = priorities[p]
				end
			end

			# Helper method for the options parser that for finish
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_finish opts, colors
				opts.separator ""
				opts.separator "  *".colorize(colors[:cyan])  + " finish , f".colorize(colors[:yellow]) +  
				" marks a task as finished".colorize(colors[:magenta])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:finish].colorize(colors[:red])
				opts.on('-n',  'references a task by its number') do |n|
					OPTIONS[:is_num] = true
				end
			end

			# Helper method for the options parser for undo
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_undo opts, colors
				opts.separator ""
				opts.separator "  *".colorize(colors[:cyan])  + " undo, u".colorize(colors[:yellow]) +  
				" undos a completed task".colorize(colors[:magenta])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:undo].colorize(colors[:red])
				opts.separator "    -n                               references a task by its number"
			end

			# Helper method for the options parser for clear
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_clear opts, colors
				opts.separator ""
				opts.separator "  *".colorize(colors[:cyan])  + " clear".colorize(colors[:yellow]) +  
				" clears a completed tasks".colorize(colors[:magenta])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:clear].colorize(colors[:red])
				opts.on('-a', 'resets the entire list') do
					OPTIONS[:clear_all] = true
				end
			end

			# Helper method for the options parser for remove
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_remove opts, colors
				opts.separator ""
				opts.separator "  *".colorize(colors[:cyan])  + " remove, rm".colorize(colors[:yellow]) +  
				" removes the list completely.".colorize(colors[:magenta])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:remove].colorize(colors[:red])
			end

			# Helper method for the options parser that for set
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_set opts, colors
				opts.separator ""
				opts.separator "  *".colorize(colors[:cyan]) + " set, s".colorize(colors[:yellow]) + 
				" adds additional information to a task".colorize(colors[:magenta])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:set].colorize(colors[:red])
				opts.separator "    -p TYPE                          set the priority of the task to one of the \n" + 
				"                                     following. Default is medium"
				opts.separator "    -n                               references a task by its number"
			end

			# Helper method for the options parser for help and display working list
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_other opts, colors
				opts.separator ""
				opts.separator "Other Options: ".colorize(colors[:green])

				#todo -h
				opts.on('-h', '--help', 'displays this screen' ) do
					puts opts
					exit
				end
				#todo -w
				opts.on('-w', "displays the name of the current list") do
					puts "Working list is #{Config[:working_list_name]}"
					exit
				end
			end

			# Helper method for the options parser for help and display working list
			#
			# @param opts the options switch
			# @param [Hash] colors the color hash
			def options_config opts, colors
				opts.separator ""
				opts.separator "Configuration Options: ".colorize(colors[:green])
				opts.separator "    usage: ".colorize(colors[:cyan]) + USAGE[:config].colorize(colors[:red])

				#todo -h
				opts.on('--color-scheme SCHEME', ["light", "dark", "none"],  "State whether you are using a light" , 
					"scheme or dark scheme.  This is used","for the text colors.  If none work",  "with your current 
					color scheme,", "you can turn it off.  Default is light." ) do |scheme|
					Config[:color] = scheme
					exit
				end
				#todo -w
				opts.on('--width WIDTH', Integer, "Changes the width for formatting") do |width|
					Config[:width] = width
					exit
				end
			end

			# Print out the tasks
			#
			# @param [Integer] completed whether to print out completed or uncompleted 
			# 								 items. 0 if completed. 1 if not
			# @param [Dataset] tasks the dataset of tasks to print out
			# @param [Hash] colors the color hash
			def print_tasks completed, tasks, colors
				priority = {
					0 => "**",
					1 => "*",
					2 => ""
				}
				tasks.each do |task|
					next if task[:Completed] == completed
					printf "%2s".colorize(colors[:magenta]), priority[task[:Priority]]
					printf "%3d. ".to_s.colorize(colors[:yellow]), task[:Task_number]
					split_v = split task[:Name], Config[:width]-7
					puts split_v[0]
					split_v.shift
					split_v.each do |line|
						printf "      %s\n", " " + line
					end
				end
			end

			# print asterisks
			# 
			# @param [Hash] colors the color hash
			def print_stars colors
				Config[:width].times do 
					print "*".colorize(colors[:red])
				end
			end

			# print the header out
			#
			# @param [Hash] colors the color hash
			def print_header colors
				Helpers::CLI::print_stars colors
				puts
				split_name = split Config[:working_list_name], Config[:width]
				split_name.each do |line|
					puts line.center(Config[:width]).colorize(colors[:cyan])
				end
				Helpers::CLI::print_stars colors
			end
		end
	end
end