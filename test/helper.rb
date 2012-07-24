# require 'rubygems'
# require 'bundler'
# begin
# 	Bundler.setup(:default, :development)
# rescue Bundler::BundlerError => e
# 	$stderr.puts e.message
# 	$stderr.puts "Run `bundle install` to install missing gems"
# 	exit e.status_code
# end
# require 'test/unit'
# require 'shoulda'

# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# $LOAD_PATH.unshift(File.dirname(__FILE__))
# require 'to-do'

# class Test::Unit::TestCase
# 	def add_tasks
# 		@list.add "Cook dinner"
# 		@list.add "Write Paper"
# 		@list.add "Do Laundry"
# 		@list.add "Clean things"
# 		@list.add "Jump up and down"
# 	end

# 	def finish_tasks
# 		@list.finish 2, true
# 		@list.finish "Clean Things", false
# 		@list.finish "jUmP up AND down", false
# 	end
# end
