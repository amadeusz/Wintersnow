class Genotype < ActiveRecord::Base
  validates_presence_of :genotyp
  validates_uniqueness_of :genotyp
end
