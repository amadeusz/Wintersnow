class Address < ActiveRecord::Base
	#has_many :messages
	
	#set_primary_key :klucz
	validates_presence_of :adres
	validates_presence_of :klucz
	validates_uniqueness_of :klucz
end
