class Address < ActiveRecord::Base
	has_many :messages
	# validates :klucz, :presence => true
	validates :adres, :presence => true,  :uniqueness =>  { :scope => [:xpath, :css, :regexp] }
end
