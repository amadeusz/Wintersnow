class Haslo < ActiveRecord::Migration
	def self.up
		add_column :users, :haslo, :string
	end
	
	def self.down
		remove_column :users, :haslo
	end
end
