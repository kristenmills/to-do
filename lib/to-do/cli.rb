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

		def display name
			puts "********************************".colorize(:light_red)
			puts name.center(32).colorize(:light_cyan)
			puts "********************************".colorize(:light_red)
			puts
			puts "Todo:".colorize(:light_green)
			WORKING_LIST.tasks.each do |k,v|
				printf "%4d. ".to_s.colorize(:light_yellow), k
				puts v
			end
			print "\nCompleted:".colorize(:light_green)
			printf "%36s\n", "#{WORKING_LIST.completed_count}/#{WORKING_LIST.count}".colorize(:light_cyan)
			WORKING_LIST.completed_tasks.each do |k,v|
				printf "%4d. ".to_s.colorize(:light_yellow), k
				puts v
			end
			puts
		end

		#use Option parser to parse command line arguements
		def parse
			options = {
					:is_num => false,
					:clear_all => false
				}
			optparse = OptionParser.new do |opts|
				opts.version = "1.0.3"
				opts.banner = "Usage: todo [COMMAND] [option] [arguments]"
				opts.separator "Commands:"
				opts.separator "    add				adds the task to the working list"
				opts.separator "    finish			marks the task as completed"
				opts.separator "    clear 			clears completed tasks"
				opts.separator "    undo 			undos a completed task"
				opts.separator "    create			creates a new list or switches to existing"
				opts.separator "    switch 			creates a new list or switches to existing"
				opts.separator "    display 			displays the list"
				opts.separator "Options: "
				opts.on('-n', 'finish or undo, the task given is a number') do 
					options[:is_num] = true
				end
				opts.on('-a', 'for clear, will reset the entire list') do 
					options[:clear_all] = true
				end
				opts.on('-h', '--help', 'Display this screen' ) do
					puts opts
					return 
				end
			end
			optparse.parse!
			if ARGV.count > 0
				case ARGV[0]
				when "add"
					ARGV.count > 1 ? WORKING_LIST.add(ARGV[1..-1].join(' '))  : puts("Invalid Command")
				when "finish"
					WORKING_LIST.finish ARGV[1..-1].join(' '), options[:is_num]
				when "clear"
					WORKING_LIST.clear options[:clear_all]
				when "display"
					self.display WORKING_LIST.name
				when "create", "switch"
					if File.exists?(File.join(Config[:lists_directory], ARGV[1..-1].join('_').downcase + '.yml'))
						Config[:working_list_name] = ARGV[1..-1].join('_').downcase
						puts "Switch to #{ARGV[1..-1].join(' ')}"
					else 
						ARGV.count > 1 ? List.new(ARGV[1..-1].join(' ')) : puts("Invalid Command")
					end
				when "undo"
					WORKING_LIST.undo ARGV[1..-1].join(' '), options[:is_num]
				else
					puts "Invalid Command"
				end
			end
		end
	end
end