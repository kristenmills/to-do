require 'yaml'
# The module that monitors the config.
# similar to SSam Goldstein's config.rb for time trap
# https://github.com/samg/timetrap/
module Todo
	module Config
		extend self
		PATH = File.join(ENV['HOME'], '.to-do', 'config.yml')
		
		#default values
		def defaults
			{
				# the location of all all your list yaml files
				'lists_directory' => File.join(ENV["HOME"],".to-do","lists"), 
				# the current working list
				'working_list_name' => "default_list"
			}
		end

		#accessor for values in the config
		def [] key
			fileval = YAML.load_file PATH
			defaults.merge(fileval)[key]
		end

		#setter for keys in config
		def []= key, value
			fileval = YAML.load_file PATH
			configs = defaults.merge(fileval)
			configs[key] = value
			File.open(PATH, 'w') do |fh|
				fh.puts(configs.to_yaml)
			end
		end

		#writes the config file path
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
