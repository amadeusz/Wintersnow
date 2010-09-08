class CreateGenotypes < ActiveRecord::Migration
  def self.up
    create_table :genotypes do |t|
      t.string :genotyp

      t.timestamps
    end
    
    add_index :genotypes, :genotyp, {:unique => true}
  end
  
  def self.down
    drop_table :genotypes
  end
end
