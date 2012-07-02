#to-do (In development)

A simple command line todo application. The app is still in development and this readme reflects the state it will be in at first release.

##Install
	curl -s https://raw.github.com/kristenmills/to-do.git | sh
Then you should be good to go!

##Features
* Basic to-do list functionality
* Named list
* Add items
* Delete items
* Clear entire list
* Display list

##How to Use
Sets the name of the list

	todo -s My New Todo List

Add some tasks to the working list

	todo -a Cook dinner
	todo -a Write Paper
	todo -a Do Laundy
	todo -a Clean Things
	
Display the list
	
	todo -d
	
	********************************
	*       My New Todo List       *
	********************************
	
	1. Cook Dinner
	2. Write Paper
	3. Do Laundry
	4. Clean Things
	
	Completed:					0/4
		None
	
Finish a task

	todo -f 2
	todo -f Clean Things
	
Display the list again 

	todo -d
	
	********************************
	*       My New Todo List       *
	********************************

		1. Cook Dinner
		3. Do Laundry

	Completed:					2/4
		2. Write Paper
		4. Clean Things
		
To clear the entire list
	
	todo -c
	
You can see the usage details with
	
	todo -h
	
or

	todo --help

##Future Plans
* Multiple lists
* Delete list
* Undo finishing an item
* Clear just completed (or incompleted) items 

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