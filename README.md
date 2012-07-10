#to-do 1.0.3

A simple command line todo application. 

##What's New in 1.0.3
* Colored list display
* Bug fixes

##Install
	gem install to-do

##Features
* Basic todo list functionality
	* Add items
	* Delete items
* Multiple lists
* Clear entire list
* Display list

##How to Use

###Create a new todo list or switch to an existing list

	todo create My New Todo List
	todo switch My Existing List

###Add some tasks to the current list

	todo add Cook dinner
	todo add Write Paper
	todo add Do Laundy
	todo add Clean Things
	
###Display the current list
	
	todo display
	
	********************************
	*       My New Todo List       *
	********************************
	
	1. Cook Dinner
	2. Write Paper
	3. Do Laundry
	4. Clean Things
	
	Completed:					0/4
	
###Finish a task

	todo finish -n 2
	todo finish Clean Things
	
###Display the current list again 

	todo display
	
	********************************
	*       My New Todo List       *
	********************************

	    1. Cook Dinner
	    3. Do Laundry

	Completed:					2/4
	    2. Write Paper
	    4. Clean Things
		
###Clear completed items 
	
	todo clear

###Clear the entire list and reset the count

	todo clear -a
	
###View usage details
	
	todo -h
	
or

	todo --help

##Future Plans
* Delete list
* Undo finishing an item

##Contributing to to-do
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

##Copyright

Copyright (c) 2012 Kristen Mills. See LICENSE.txt for
further details.
