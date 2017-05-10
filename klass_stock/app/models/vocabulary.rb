class Vocabulary < ActiveRecord::Base
  validates_uniqueness_of :code, :en
end
