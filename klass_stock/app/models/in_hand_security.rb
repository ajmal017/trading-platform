class InHandSecurity < ActiveRecord::Base
  scope :available, -> { where 'sum_volume > 0' }
end
