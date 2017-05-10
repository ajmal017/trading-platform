class IntradayQuote < ActiveRecord::Base
  validates :symbol, presence: true
end
