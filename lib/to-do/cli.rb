require 'optparse'

$data = ENV["HOME"]+"/.todo/lists/"
$settings = ENV["HOME"]+"/.todo/config.yml"

module Todo
	module CLI
		extend self
		# Displays the given todo list 
		def display name
			puts "********************************"
			puts name.center(32)
			puts "********************************"
		end

		#use Option parser to parse command line arguements
		def parse
			optparse = OptionParser.new do |opts|
				opts.banner = "Usage: todo [option] [arguments]"
				opts.on('-d', '--display' , 'Displays the  list' ) do |list|
					self.display "My New To-do List"
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