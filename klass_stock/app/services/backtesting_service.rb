require 'indicator/mixin'


class BacktestingService
  def self.run(name, symbol, strategy, ma_type=nil, from_date=nil, to_date=nil)
    historical_data = []
    quotes = Quote.where("symbol = ?", symbol)
    if from_date && to_date
      quotes = quotes.where("date >= ? AND date <= ?", from_date, to_date)
    elsif from_date
      quotes = quotes.where("date >= ?", from_date)
    elsif to_date
      quotes = quotes.where("date <= ?", to_date)
    end
    return if quotes.empty?
    quotes.order(:date).each do |quote|
      historical_data << {
        date: quote[:date],
        open: quote[:open],
        high: quote[:high],
        low: quote[:low],
        close: quote[:close],
        volume: quote[:volume]
      }
    end

    case strategy
    when '1ma'
      strategy = Strategy::OneMa.new(historical_data, ma_type)
    when '5ma_ri'
      strategy = Strategy::FiveMaRider.new(historical_data, ma_type)
    when '5ma_co'
      strategy = Strategy::FiveMaCrossover.new(historical_data, ma_type)
    when '5ma_co_v2'
      strategy = Strategy::FiveMaCrossoverV2.new(historical_data, ma_type)
    when '10ma_ri'
      strategy = Strategy::TenMaRider.new(historical_data, ma_type)
    when '10ma_co'
      strategy = Strategy::TenMaCrossover.new(historical_data, ma_type)
    when '10ma_co_v2'
      strategy = Strategy::TenMaCrossoverV2.new(historical_data, ma_type)
    when 'spread'
      strategy = Strategy::Spread.new(historical_data)
    when 'ma_spread'
      strategy = Strategy::MaSpread.new(historical_data)
    when 'macd'
      strategy = Strategy::MACD.new(historical_data)
    when 'adx'
      strategy = Strategy::ADX.new(historical_data)
    else
      return
    end

    unless name
      from = historical_data.first[:date].strftime('%Y')
      to = historical_data.last[:date].strftime('%Y')
      name = "#{symbol} (#{from}-#{to})"
    end
    puts name

    portfolio = Portfolio.create(name: name)
    portfolio.user_id = 1
    portfolio.save

    # last_date = 0
    # last_price = 0
    volume = 100

    while true
      break if strategy.run do |signal|
        if signal
          if volume > 0
            order = Order.new(
              symbol: symbol,
              datetime: signal[:date],
              price: signal[:price],
              volume: volume,
              side: signal[:side]
            )
            order.portfolio_id = portfolio.id
            order.save

            # last_date = signal[:date]
            # last_price= signal[:price]
          end
        end
        signal.nil?
      end
    end

    # For DW, sell all on the last trading date
    # InHandSecurity.where(portfolio_id: portfolio.id).each do |sec|
    #   if sec.symbol == symbol and sec.sum_volume > 0
    #     order = Order.new(
    #       force_sell: true,
    #       symbol: symbol,
    #       datetime: last_date,
    #       price: last_price,
    #       volume: sec.sum_volume,
    #       side: 'S'
    #     )
    #     order.portfolio_id = portfolio.id
    #     order.save
    #   end
    # end

  end
end
