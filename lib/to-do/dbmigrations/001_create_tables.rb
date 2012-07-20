require 'sequel'

Sequel.migration do
	up do
		if !table_exists? :Tasks
			create_table :Tasks do
				primary_key :Id
				Integer :Task_number
				String :Text
				Integer :Completed
			end 
		end	
		if !table_exists? :Lists
			create_table :Lists do 
				primary_key :Id
				String :Name
				Integer :Total
			end
		end
		if !table_exists? :Task_list
			create_table :Task_list do 
				Integer :Task_id
				Intager :List_id
			end
		end
	end
	down do
		if table_exists? :Tasks
			create_table :Tasks do
				primary_key :Id
				Integer :Task_number
				String :Text
				Integer :Completed
			end 
		end	
		if table_exists? :Lists
			create_table :Lists do 
				primary_key :Id
				String :Name
				Integer :Total
			end
		end
		if table_exists? :Task_list
			create_table :Task_list do 
				Integer :Task_id
				Intager :List_id
			end
		end
	end
end