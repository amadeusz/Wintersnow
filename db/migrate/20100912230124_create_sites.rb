class CreateSites < ActiveRecord::Migration 
  def self.up 
    create_table :sites do |t| 
      t.references :address
      t.string :opis 
      t.references :user
    end  
  end  
  def self.down 
    drop_table :sites
  end 
end 
