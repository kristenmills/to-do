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

		#use option parser to parse command line arguments
		def parse
			options = {
					:is_num => false,
					:clear_all => false
				}
			optparse = OptionParser.new do |opts|
				opts.version = "1.1.0"
				opts.banner = "Usage: todo [COMMAND] [option] [arguments]"
				opts.separator "Commands:"
				opts.separator "    <blank>, display, d              displays the current list"
				opts.separator "    add, a                           adds the task to the current list"
				opts.separator "    finish, f                        marks the task as completed"
				opts.separator "    clear                            clears completed tasks"
				opts.separator "    undo, u                          undos a completed task"
				opts.separator "    create, switch                   creates a new list or switches to an existing one"
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
					self.display WORKING_LIST.name
				when "finish", "f"
					WORKING_LIST.finish ARGV[1..-1].join(' '), options[:is_num]
					self.display WORKING_LIST.name
				when "clear"
					WORKING_LIST.clear options[:clear_all]
				when "display", "d"
					self.display WORKING_LIST.name
				when "create", "switch"
					if File.exists?(File.join(Config[:lists_directory], ARGV[1..-1].join('_').downcase + '.yml'))
						Config[:working_list_name] = ARGV[1..-1].join('_').downcase
						puts "Switch to #{ARGV[1..-1].join(' ')}"
						self.display WORKING_LIST.name
					else
						ARGV.count > 1 ? List.new(ARGV[1..-1].join(' ')) : puts("Invalid Command")
					end
				when "undo", "u"
					WORKING_LIST.undo ARGV[1..-1].join(' '), options[:is_num]
					self.display WORKING_LIST.name
				else
					puts "Invalid Command"
				end
			else
				#if no ARGs are given, do what "display" would do
				self.display WORKING_LIST.name
			end
		end
	end
end
