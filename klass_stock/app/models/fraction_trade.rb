class FractionTrade < ActiveRecord::Base
  validates :symbol, presence: true
  validates :symbol, uniqueness: true

  scope :active, -> { where active: true }
end
