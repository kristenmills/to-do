require 'optparse'
require 'yaml'
require 'colorize'
$data = ENV["HOME"]+"/.todo/lists/"
$settings = ENV["HOME"]+"/.todo/config.yml"

module Todo
	module CLI
		extend self
		# Displays the given todo list
		WORKING_LIST=YAML.load_file(File.join(Config[:lists_directory],
			Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory],
			Config[:working_list_name]+'.yml'))

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

		#use option parser to parse command line arguments
		def parse
			options = {
					:is_num => false,
					:clear_all => false
				}
			optparse = OptionParser.new do |opts|
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
					options[:is_num] = true
				end
				opts.on('-a', 'with clear, resets the entire list') do
					options[:clear_all] = true
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
			optparse.parse!
			if ARGV.count > 0
				case ARGV[0]
				when "add", "a"
					ARGV.count > 1 ? WORKING_LIST.add(ARGV[1..-1].join(' ')) : puts("Invalid Command")
					self.display 
				when "finish", "f"
					WORKING_LIST.finish ARGV[1..-1].join(' '), options[:is_num]
					self.display 
				when "clear"
					WORKING_LIST.clear options[:clear_all]
				when "display", "d"
					self.display 
				when "create", "switch"
					if File.exists?(File.join(Config[:lists_directory], ARGV[1..-1].join('_').downcase + '.yml'))
						Config[:working_list_name] = ARGV[1..-1].join('_').downcase
						puts "Switch to #{ARGV[1..-1].join(' ')}"
						new_list = YAML.load_file(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml'))
						self.display new_list
					else 
						ARGV.count > 1 ? List.new(ARGV[1..-1].join(' ')) : puts("Invalid Command")
						new_list = YAML.load_file(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml')) if File.exists?(File.join(Config[:lists_directory], 
						Config[:working_list_name]+'.yml'))
						self.display new_list
					end
				when "undo", "u"
					WORKING_LIST.undo ARGV[1..-1].join(' '), options[:is_num]
					self.display 
				else
					puts "Invalid Command"
				end
			else
				#if no ARGs are given, do what "display" would do
				self.display 
			end
		end
	end
end
