require 'yaml'
require 'optparse'

$data = ENV["HOME"]+"/.todo/data.yml"
$settings = ENV["HOME"]+"/.todo/settings.yml"

module Todo
	module CLI

		# Displays the given todo list 
		def self.display 
			puts "To-do List:\n     "
		end

		#use Option parser to parse command line arguements
		def self.parse
			optparse = OptionParser.new do |opts|
				opts.banner = "Usage: todo [option] [Space seperated values]"
				opts.on('-d', '--display' , 'Displays the  list' ) do |list|
					self.display 
					return
				end
				opts.on('-s', '--set-name NAME' ,'Sets the name of the list') do |list|
					val = ARGV.count == 0 ? list : list + " " + ARGV.join(" ")
					return
				end
				opts.on('-a', '--add TASK', 'Adds the given task to the  list') do |task|
					val = ARGV.count == 0 ? list : list + " " + ARGV.join(" ")
					return
				end
				opts.on('-f', '--finish TASK', 'checks off the task on the list') do |num|
					val = ARGV.count == 0 ? list : list + " " + ARGV.join(" ")
					return
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
  	end
	end
end