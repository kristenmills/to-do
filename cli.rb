require 'yaml'
require 'optparse'

$data = ENV["HOME"]+"/.todo/data.yml"
$settings = ENV["HOME"]+"/.todo/settings.yml"

module Todo
	module CLI

		# Displays the given todo list 
		def self.display list_name
			puts "To-do List:\n     "
		end

		#use Option parser to parse command line arguements
		def self.parse
			optparse = OptionParser.new do |opts|
				opts.banner = "Usage: todo [option] [Space seperated values]"
				opts.on('-d', '--display [LIST]' , 'Displays the working or given list' ) do |list|
					self.display "x"
					return
				end
				opts.on('-s', '--set LIST' ,'Sets the working list to the given list') do |list|
					return
				end
				opts.on('-a', '--add TASK', 'Adds the given task to the working list') do |task|
					return
				end
				opts.on('-f', '--finish NUMBER', Integer, 'checks off the task number on the working list') do |num|
					return
				end
				opts.on('-c', '--completed [LIST]', 'Show the completed items for the working or given') do |list|
					return
				end
				opts.on('-h', '--help', 'Display this screen' ) do
    			puts opts
    			return 
    		end
    	end
    	optparse.parse!
  	end
	end
end