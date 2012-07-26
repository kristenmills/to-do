require File.join(File.dirname(__FILE__), 'helper')
require File.join(File.dirname(__FILE__),"..", "lib", "to-do.rb")
require 'fileutils'

class TestToDo < Test::Unit::TestCase
	context "Test list" do
		setup do
			@list_name = Todo::Config[:working_list_name]
			Todo::Config[:working_list_name] = 'Test list'
			@database = Sequel.sqlite Todo::Config[:task_database]
		end

		should "be empty" do
			tasks = tasks_in_list @database
			assert_equal 0, tasks.count
		end

		should "add some tasks"  do
			add_tasks
			tasks = tasks_in_list @database
			list = @database[:Lists][:Name=>Todo::Config[:working_list_name]]
			assert_equal 5, list[:Total]
			assert_equal 0, tasks.filter(:Completed=>1).count
		end

		should "finish some tasks" do
			add_tasks
			finish_tasks
			Todo::Tasks.finish "This task doesn't exist", false
			Todo::Tasks.finish 40, true
			tasks = tasks_in_list @database
			puts tasks.filter(:Completed=>1)
			puts tasks.filter(:Completed=>0)
			list = @database[:Lists][:Name=>Todo::Config[:working_list_name]]
			assert_equal 5, list[:Total]
			assert_equal 3, tasks.filter(:Completed=>1).count
			assert_equal 2, tasks.filter(:Completed=>0).count
		end

		should "undo some tasks" do
			add_tasks
			finish_tasks
			Todo::Tasks.undo 2, true
			Todo::Tasks.undo "Clean Things", false
			Todo::Tasks.undo "This task doesn't exist", false
			Todo::Tasks.undo 40, true
			tasks = tasks_in_list @database
			list = @database[:Lists][:Name=>Todo::Config[:working_list_name]]
			assert_equal 5, list[:Total]
			assert_equal 1, tasks.filter(:Completed=>1).count
			assert_equal 4, tasks.filter(:Completed=>0).count
		end

		should "clear list" do
			add_tasks
			finish_tasks
			Todo::Tasks.clear false
			tasks = tasks_in_list @database
			list = @database[:Lists][:Name=>Todo::Config[:working_list_name]]
			assert_equal 5, list[:Total]
			assert_equal 0, tasks.filter(:Completed=>1).count
			assert_equal 2, tasks.filter(:Completed=>0).count
			Todo::Tasks.finish 3, true
			Todo::Tasks.clear true
			list = @database[:Lists][:Name=>Todo::Config[:working_list_name]]
			assert_nil list
			assert_equal 0, tasks.filter(:Completed=>1).count
			assert_equal 0, tasks.filter(:Completed=>0).count
		end

		teardown do
			Todo::Tasks.clear true
			Todo::Config[:working_list_name] = @list_name
		end
	end
end
