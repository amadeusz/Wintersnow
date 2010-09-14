class Address < ActiveRecord::Base
	has_many :messages
	has_many :sites
  has_many :users, :through => :sites
	# validates :klucz, :presence => true
	validates :adres, :presence => true,  :uniqueness =>  { :scope => [:xpath, :css, :regexp] }
end
