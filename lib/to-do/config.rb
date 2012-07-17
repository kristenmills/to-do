require 'yaml'

module Todo
	# The module that contains the methods relevant to configurations and custom
	# configuration in config.yml
	#
	# similar to Sam Goldstein's config.rb for timetrap
	# @see https://github.com/samg/timetrap/
	module Config
		extend self
		# The path to the the config file
		PATH = File.join(ENV['HOME'], '.to-do', 'config.yml')

		# Default config key value pairs
		#
		# @return [Hash<Symbol,Object>] the default configurations in a hash
		def defaults
			{
				# the location of all all your list yaml files
				:lists_directory => File.join(ENV["HOME"],".to-do","lists"),
				# a sqlite3 databse that contains all of the tasks 
				:task_database => File.join(ENV["HOME"], ".to-do", "to-do.sqlite"), 
				# the current working list
				:working_list_name => "default_list", 
				# does the working list actually exist
				:working_list_exists => false, 
				# default width for formatting
				:width => 50
			}
		end

		# Overloading [] operator
		#
		# Accessor for values in the config
		#
		# @param [Symbol] key the key in the config hash
		# @return [Object] the value associated with that key
		def [] key
			fileval = YAML.load_file PATH
			defaults.merge(fileval)[key]
		end

		# Overloading []= operator
		#
		# Setter for values in the Config hash
		# 
		# @param [Symbol] key the key you are setting a value for
		# @param [Object] value the value you associated with the key 
		def []= key, value
			fileval = YAML.load_file PATH
			configs = defaults.merge(fileval)
			configs[key] = value
			File.open(PATH, 'w') do |fh|
				fh.puts(configs.to_yaml)
			end
		end

		# Writes the configs to the file config.yml
		def write
			configs = if File.exist? PATH
				defaults.merge(YAML.load_file PATH)
			else
				defaults
			end
			File.open(PATH, 'w') do |fh|
				fh.puts(configs.to_yaml)
			end
		end
	end
end
