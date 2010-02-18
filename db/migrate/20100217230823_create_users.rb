class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :klucz
      t.text :obserwowane

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
