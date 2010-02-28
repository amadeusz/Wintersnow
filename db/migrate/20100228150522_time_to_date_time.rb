class TimeToDateTime < ActiveRecord::Migration
  def self.up
  	change_column :messages, :data, :datetime
  end

  def self.down
	change_column :messages, :data, :time
  end
end
