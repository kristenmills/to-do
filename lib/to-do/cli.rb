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
			options = {:is_num => false}
			optparse = OptionParser.new do |opts|
				opts.banner = "Usage: todo [COMMAND] [option] [arguments]"
				opts.on('-d', '--display' , 'Displays the  list' ) do |list|
					self.display WORKING_LIST.name
					return
				end
				opts.on('-s', '--set-name NAME' ,'Sets the current list or creates a new one') do |name|
					name = ARGV.count == 0 ? name : name + " " + ARGV.join(" ")
					if File.exists?(File.join(Config['lists_directory'], name.downcase.gsub(/ /, '_') + '.yml'))
						Config['working_list_name'] = name.downcase.gsub(/ /, '_')
					else 
						list = List.new name
					end
				end
				opts.on('-n', '--num', 'checks off the task on the list') do |num|
					options[:is_num] = true
				end
				opts.on('-c', '--clear', 'clears the list') do |list|
					return
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
    			WORKING_LIST.add  ARGV[1..-1].join(' ')
    		when "finish"
    			WORKING_LIST.finish ARGV[1..-1].join(' '), options[:is_num]
    		end
    	end
  	end
	end
end