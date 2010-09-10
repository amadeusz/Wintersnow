class AddRegexpToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :regexp, :string
  end

  def self.down
    remove_column :addresses, :regexp
  end
end
