class DodanieKomunikatow < ActiveRecord::Migration
	def self.up
		add_column :addresses, :komunikaty, :text
	end
	
	def self.down
		remove_column :addresses, :komunikaty
	end
end
