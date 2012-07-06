#to-do 1.0

A simple command line todo application. The app is still in development and this readme reflects the state it will be in at first release.

##Install
	curl https://raw.github.com/kristenmills/to-do/master/install.sh -o - | sh
Then you should be good to go!

##Features
* Basic to-do list functionality
* Multiple lists
* Add items
* Delete items
* Clear entire list
* Display list

##How to Use
Creates a new todo list or switch to an already existing list

	todo create My New Todo List
	todo switch My Existing List

Add some tasks to the working list

	todo add Cook dinner
	todo add Write Paper
	todo add Do Laundy
	todo add Clean Things
	
Display the list
	
	todo display
	
	********************************
	*       My New Todo List       *
	********************************
	
	1. Cook Dinner
	2. Write Paper
	3. Do Laundry
	4. Clean Things
	
	Completed:					0/4
	
Finish a task

	todo finish -n 2
	todo finish Clean Things
	
Display the list again 

	todo display
	
	********************************
	*       My New Todo List       *
	********************************

	    1. Cook Dinner
	    3. Do Laundry

	Completed:					2/4
	    2. Write Paper
	    4. Clean Things
		
To clear the completed items 
	
	todo clear

To clear the entire list and reset the count

	todo clear -a
	
You can see the usage details with
	
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