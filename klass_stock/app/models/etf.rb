class ETF < ActiveRecord::Base
  scope :active, -> { where active: true }
end
