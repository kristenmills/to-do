module Todo

	#A module that contains helper methods 
	module Helpers
		extend self

		DATABASE = Sequel.sqlite Todo::Config[:task_database]

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
				:set => "todo set|s [-p {high, medium, low}] [-n <TASK_NUMBER>] [<TASK>]"
			}

			def options_title opts
				version_path = File.expand_path("../../VERSION", File.dirname(__FILE__))
				opts.version = File.exist?(version_path) ? File.read(version_path) : ""
				opts.banner = "Todo: A simple command line todo application\n\n".colorize(:light_green) +
				"    usage:".colorize(:light_cyan) + " todo [COMMAND] [option] [arguments]".colorize(:light_red)
				opts.separator ""
				opts.separator "Commands:".colorize(:light_green)
			end

			def options_create opts
				#todo create, switch
				opts.separator "  *".colorize(:light_cyan)  + " create, switch".colorize(:light_yellow) +  
				" creates a new list or switches to an existing one".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:create].colorize(:light_red)
			end

			def options_display opts
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " display, d".colorize(:light_yellow) +  
				" displays the current list".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:display].colorize(:light_red)
				opts.on('-s TYPE', [:p, :n], "sorts the task by ") do |s|
					OPTIONS[:sort] = s
				end
			end

			def options_add opts
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " add, a".colorize(:light_yellow) +  
				" adds the task to the current list".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:add].colorize(:light_red)
				opts.on('-p PRIORITY', ["high", "medium", "low"], 'set the priority of the task to one of the following.\n' + 
				'                                                    Default is medium') do |p|
					priorities = {
						"high" => 0,
						"medium" => 1,
						"low" => 2
					}
					OPTIONS[:change_priority] = true
					OPTIONS[:priority] = priorities[p]
				end
			end

			def options_finish opts
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " finish , f".colorize(:light_yellow) +  
				" marks a task as finished".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:finish].colorize(:light_red)
				opts.on('-n',  'references a task by its number') do |n|
					OPTIONS[:is_num] = true
				end
			end

			def options_undo opts
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " undo, u".colorize(:light_yellow) +  
				" undos a completed task".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:undo].colorize(:light_red)
				opts.separator "    -n                               references a task by its number"
			end

			def options_clear opts
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " clear".colorize(:light_yellow) +  
				" clears a completed tasks".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:clear].colorize(:light_red)
				opts.on('-a', 'resets the entire list') do
					OPTIONS[:clear_all] = true
				end
			end

			def options_remove opts
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan)  + " remove, rm".colorize(:light_yellow) +  
				" removes the list completely.".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:remove].colorize(:light_red)
			end

			def options_set opts
				opts.separator ""
				opts.separator "  *".colorize(:light_cyan) + " set, s".colorize(:light_yellow) + 
				" adds additional information to a task".colorize(:light_magenta)
				opts.separator "    usage: ".colorize(:light_cyan) + USAGE[:set].colorize(:light_red)
				opts.separator "    -p TYPE                          set the priority of the task to one of the following.\n" + 
				"                                     Default is medium"
				opts.separator "    -n                               references a task by its number"
			end

			def options_other opts
				opts.separator ""
				opts.separator "Other Options: ".colorize(:light_green)

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

			def print_tasks completed, tasks
				priority = {
					0 => "**",
					1 => "*",
					2 => ""
				}
				tasks.each do |task|
					next if task[:Completed] == completed
					printf "%2s".colorize(:light_magenta), priority[task[:Priority]]
					printf "%3d. ".to_s.colorize(:light_yellow), task[:Task_number]
					split_v = Helpers::split task[:Name], Config[:width]-7
					puts split_v[0]
					split_v.shift
					split_v.each do |line|
						printf "      %s\n", " " + line
					end
				end
			end
		end
	end
end