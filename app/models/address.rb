class Address < ActiveRecord::Base
	#has_many :messages
	validates :adres, :presence => true, :uniqueness => true, :length => { :within => 8..255 }
end
