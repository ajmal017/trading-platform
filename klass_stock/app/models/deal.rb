class Deal < ActiveRecord::Base
  scope :loss, -> { where 'realized_pl < 0' }
end
