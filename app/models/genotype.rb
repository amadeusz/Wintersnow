class Genotype < ActiveRecord::Base
	validates :genotyp, :presence => true, :uniqueness => true
end
