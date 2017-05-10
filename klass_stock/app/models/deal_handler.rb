class DealHandler
  TRADING_FEE = 0.00168846

  def initialize(order, deal, security)
    @order = order
    @deal = deal
    @security = security
  end

  def handle
    if @order.sell? and @order.volume > 0
      if @security.sum_volume > 0 and @security.sum_volume >= @order.volume
        avg_price = (@security.sum_price / @security.sum_volume).round(2)
        @deal.realized_pl = calculate_realized_pl(avg_price, @order.price, @order.volume)
        # return false if not @order.force_sell and @deal.realized_pl <= 0
        @deal.portfolio_id = @order.portfolio_id
        @deal.symbol = @order.symbol
        @deal.bought_at = @order.latest_bought.datetime
        @deal.bought_price = avg_price
        @deal.sold_at = @order.datetime
        @deal.sold_price = @order.price
        @deal.volume = @order.volume
        @deal.percent_pl = @deal.realized_pl / @net_buy * 100
        @deal.save

        sum_volume = @security.sum_volume
        @security.sum_volume = @security.sum_volume - @order.volume
        @security.sum_price = @security.sum_volume * (@security.sum_price / sum_volume)
        @security.save
      end
    elsif @order.buy?
      # return false if @security.sum_volume >= 10000
      if @security.new_record?
        @security.portfolio_id = @order.portfolio_id
        @security.symbol = @order.symbol
        @security.sum_volume = @order.volume
        @security.sum_price = @order.price * @order.volume
        @security.save
      else
        @security.sum_volume += @order.volume
        @security.sum_price += @order.price * @order.volume
        @security.save
      end
    end
  end

  def self.calculate_net_buy(price, volume)
    (price + (price * TRADING_FEE)) * volume
  end
  def calculate_net_buy(price, volume)
    @net_buy = DealHandler.calculate_net_buy(price, volume)
    @net_buy
  end

  def self.calculate_net_sell(price, volume)
    (price - (price * TRADING_FEE)) * volume
  end
  def calculate_net_sell(price, volume)
    DealHandler.calculate_net_sell(price, volume)
  end

  def self.calculate_realized_pl(buy, sell, volume)
    calculate_net_sell(sell, volume) - calculate_net_buy(buy, volume)
  end
  def calculate_realized_pl(buy, sell, volume)
    # Why not call DealHandler.calculate_realized_pl ?
    # because I need to create a '@net_buy'
    calculate_net_sell(sell, volume) - calculate_net_buy(buy, volume)
  end
end
