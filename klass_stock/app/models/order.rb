class Order < ActiveRecord::Base
  # attr_accessor :force_sell

  validates :symbol, :datetime, :price, :volume, :side, presence: true

  belongs_to :portfolio

  # before_save :finalize
  before_create :handle_deal

  scope :bought_side, -> { where side: 'B' }
  scope :sold_side, -> { where side: 'S' }

  def buy?
    side == 'B'
  end

  def sell?
    side == 'S'
  end

  def latest_bought
    Order.where(portfolio_id: portfolio_id, symbol: symbol, side: 'B')
         .order('datetime desc').limit(1).first
  end

  private

  def finalize
    self.symbol.upcase!
  end

  def handle_deal
    security = InHandSecurity.where(portfolio_id: portfolio_id, symbol: symbol).first
    security = InHandSecurity.new unless security
    DealHandler.new(self, Deal.new, security).handle
  end

end
