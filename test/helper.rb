require 'rubygems'
require 'bundler'
begin
	Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
	$stderr.puts e.message
	$stderr.puts "Run `bundle install` to install missing gems"
	exit e.status_code
end
require 'test/unit'
require 'shoulda'

#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
#$LOAD_PATH.unshift(File.dirname(__FILE__))
require File.join(File.dirname(__FILE__), '..', 'lib','to-do')

class Test::Unit::TestCase
	def tasks_in_list database
		database[:Tasks].join(:Task_list, :Tasks__id => :Task_list__Task_id).join(
		:Lists, :Lists__id => :Task_list__List_id).select(:Tasks__Task_number, :Tasks__Name, 
		:Tasks__Completed).filter(:Lists__Name => Todo::Config[:working_list_name])
	end
	def add_tasks
		Todo::Tasks.add "Cook dinner"
		Todo::Tasks.add "Write Paper"
		Todo::Tasks.add "Do Laundry"
		Todo::Tasks.add "Clean things"
		Todo::Tasks.add "Jump up and down"
	end

	def finish_tasks
		Todo::Tasks.finish 2, true
		Todo::Tasks.finish "Clean things", false
		Todo::Tasks.finish "jUmP up AND down", false
	end
end
