class Blokada < ActiveRecord::Migration
	def self.up
		add_column :addresses, :blokada, :boolean, :default => false
	end

	def self.down
		remove_column :addresses, :blokada
	end
end
