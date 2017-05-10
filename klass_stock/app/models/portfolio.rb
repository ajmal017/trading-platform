class Portfolio < ActiveRecord::Base
  validates :name, presence: true

  has_many :orders, dependent: :destroy
  has_many :deals, dependent: :destroy
  has_many :in_hand_securities, dependent: :destroy

  def calculate_all
    @_net_buy = 0
    @_net_profit = 0
    @_gross_loss = 0
    @_deals = 0
    @_win = 0
    @_loss = 0
    deals.each do |deal|
      @_net_buy += DealHandler.calculate_net_buy(deal.bought_price, deal.volume)
      @_net_profit += deal.realized_pl
      @_gross_loss += deal.realized_pl if deal.realized_pl < 0
      @_deals += 1
      @_win += 1 if deal.realized_pl > 0
      @_loss += 1 if deal.realized_pl < 0
    end
  end

  def net_buy
    return @_net_buy if @_net_buy
    calculate_all
    @_net_buy
  end

  def net_profit
    return @_net_profit if @_net_profit
    calculate_all
    @_net_profit
  end

  def percent_profit
    calculate_all unless @_net_profit
    return 0 if @_net_buy == 0
    @_net_profit / @_net_buy * 100
  end

  def gross_loss
    return @_gross_loss if @_gross_loss
    calculate_all
    @_gross_loss
  end

  def percent_loss
    calculate_all unless @_gross_loss
    return 0 if @_net_buy == 0
    @_gross_loss / @_net_buy * 100
  end

  def deals_count
    return @_deals if @_deals
    @_deals = deals.count
    @_deals
  end

  def win
    return @_win if @_win
    calculate_all
    @_win
  end

  def loss
    return @_loss if @_loss
    calculate_all
    @_loss
  end
end
