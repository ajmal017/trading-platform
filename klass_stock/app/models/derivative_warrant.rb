class DerivativeWarrant < ActiveRecord::Base
  belongs_to :company

  scope :active, -> { where active: true }
end
