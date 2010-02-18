class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :klucz
      t.string :adres
      t.datetime :data_mod
      t.datetime :data_spr
      t.string :opis

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
