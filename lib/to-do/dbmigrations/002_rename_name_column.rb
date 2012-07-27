require 'sequel'

Sequel.migration do
	up do
		rename_table :Tasks, :Old_tasks
		create_table :Tasks do
			primary_key :Id
			Integer :Task_number
			String :Name
			Integer :Completed
		end 
		self[:Tasks].insert(self[:Old_tasks])
		drop_table(:Old_tasks)
	end
	down do 
		rename_table :Tasks, :Old_tasks
		create_table :Tasks do
			primary_key :Id
			Integer :Task_number
			String :Text
			Integer :Completed
		end 
		self[:Tasks].insert(self[:Old_tasks])
		drop_table(:Old_tasks)
	end
end