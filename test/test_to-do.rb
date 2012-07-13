require File.join(File.dirname(__FILE__), 'helper')
require '../lib/to-do.rb'

class TestToDo < Test::Unit::TestCase
	context "Test list" do
		setup do
			@list_name = Todo::Config[:working_list_name]
			@list = Todo::List.new "Test List"
		end

		should "list is empty" do
			assert_equal 0, @list.count
			assert_equal 0, @list.completed_count
			assert_equal 0, @list.tasks.count
			assert_equal 0, @list.completed_tasks.count
			assert_equal "test_list" , Todo::Config[:working_list_name]
		end

		should "add some tasks"  do
			add_tasks
			assert_equal 5, @list.count
			assert_equal 0, @list.completed_count
			assert_equal 5, @list.tasks.count
			assert_equal 0, @list.completed_tasks.count
		end

		should "finish some tasks" do
			add_tasks
			finish_tasks
			@list.finish "This task doesn't exist", false
			@list.finish 40, true
			assert_equal 5, @list.count
			assert_equal 3, @list.completed_count
			assert_equal 2, @list.tasks.count
			assert_equal 3, @list.completed_tasks.count
		end

		should "undo some tasks" do
			add_tasks
			finish_tasks
			@list.undo 2, true
			@list.undo "Clean Things", false
			@list.undo "This task doesn't exist", false
			@list.undo 40, true
			assert_equal 5, @list.count
			assert_equal 1, @list.completed_count
			assert_equal 4, @list.tasks.count
			assert_equal 1, @list.completed_tasks.count
		end

		should "clear list" do
			add_tasks
			finish_tasks
			@list.clear false
			assert_equal 5, @list.count
			assert_equal 3, @list.completed_count
			assert_equal 2, @list.tasks.count
			assert_equal 0, @list.completed_tasks.count
			@list.finish 3, true
			@list.clear true
			assert_equal 0, @list.count
			assert_equal 0, @list.completed_count
			assert_equal 0, @list.tasks.count
			assert_equal 0, @list.completed_tasks.count
		end

		teardown do
			#remove list when I create that functionality
			Todo::Config[:working_list_name] = @list_name
		end
	end
end
