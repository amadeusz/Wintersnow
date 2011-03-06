class AddOwnerToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :one_user, :boolean, {:default => false}
  end

  def self.down
    remove_column :addresses, :one_user
  end
end
