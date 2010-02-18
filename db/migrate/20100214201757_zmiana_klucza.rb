class ZmianaKlucza < ActiveRecord::Migration
  def self.up
  	add_index(:addresses, :klucz, :unique => true)
  end

  def self.down
  end
end
