class ZmianaKluczaUsers < ActiveRecord::Migration
  def self.up
  	add_index(:users, :id, :unique => true)
  end

  def self.down
  	
  end
end
