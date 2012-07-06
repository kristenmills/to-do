require 'optparse'
require 'yaml'
$data = ENV["HOME"]+"/.todo/lists/"
$settings = ENV["HOME"]+"/.todo/config.yml"

module Todo
	module CLI
		extend self
		# Displays the given todo list 
		WORKING_LIST=YAML.load_file(File.join(Config['lists_directory'], 
			Config['working_list_name']+'.yml')) if File.exists?(File.join(Config['lists_directory'], 
			Config['working_list_name']+'.yml'))

		def display name
			puts "********************************"
			puts name.center(32)
			puts "********************************"
		end

		#use Option parser to parse command line arguements
		def parse
			options = {
					:is_num => false,
					:clear_all => false
				}
			optparse = OptionParser.new do |opts|
				opts.version = "0.7.0"
				opts.banner = "Usage: todo [COMMAND] [option] [arguments]"
				opts.separator "Commands:"
				opts.separator "    add				adds the task to the working list"
				opts.separator "    finish			marks the task as completed"
				opts.separator "    clear 			clears completed tasks"
				opts.separator "    create			creates a new list or switches to existing"
				opts.separator "    switch 			creates a new list or switches to existing"
				opts.separator "    display 			displays the list"
				opts.separator "Options: "
				opts.on('-n', 'for finish, the task given is a number') do 
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
    			WORKING_LIST.add  ARGV[1..-1].join(' ') if ARGV.count > 2
    		when "finish"
    			WORKING_LIST.finish ARGV[1..-1].join(' '), options[:is_num]
    		when "clear"
    			WORKING_LIST.clear options[:clear_all]
    		when "display"
    			self.display WORKING_LIST.name
    		when "create" || "switch"
    			if File.exists?(File.join(Config['lists_directory'], name.downcase.gsub(/ /, '_') + '.yml'))
						Config['working_list_name'] = name.downcase.gsub(/ /, '_')
					else 
						list = List.new name
					end
    		end
    	end
  	end
	end
end