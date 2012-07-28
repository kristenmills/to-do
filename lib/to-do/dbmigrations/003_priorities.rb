require 'sequel'

Sequel.migration do
	change do 
		add_column :Tasks, :Priority, :String, :default=>medium
	end
end