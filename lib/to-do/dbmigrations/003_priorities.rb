require 'sequel'

Sequel.migration do
	change do 
		add_column :Tasks, :Priority, :Integer, :default=>1
	end
end