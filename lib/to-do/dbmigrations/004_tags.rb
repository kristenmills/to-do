require 'sequel'

Sequel.migration do 
	change do
		create_table :Tags do 
			primary_key :Id
			String :Tag
		end
	
		create_table :Tags_Task do 
			Integer :Task_Id
			Integer :Tag_Id
		end
	end
end


