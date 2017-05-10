class GoTop
  def self.run(symbol)
    logger = Logger.new(STDOUT)
    # logger.level = Logger::DEBUG
    # logger.level = Logger::INFO
    logger.level = Logger::WARN

    quotes = Quote.where("symbol = ?", symbol)
    if defined?(from_date) && defined?(to_date)
      if from_date && to_date
        quotes = quotes.where("date >= ? AND date <= ?", from_date, to_date)
      elsif from_date
        quotes = quotes.where("date >= ?", from_date)
      elsif to_date
        quotes = quotes.where("date <= ?", to_date)
      end
    end
    return if quotes.empty?

    fee = 0.00168846
    vol = 1000
    pl = 0
    dd = 0
    price = 0
    spread = 0.01
    last_price = quotes.order(:date).first[:open]
    highest_price = last_price
    lowest_price = last_price
    cost = 0
    sum_reseted_cost = 0
    sum_reseted_pl = 0
    sum_reseted_dd = 0
    zone_size = 10
    zones = []
    zone_size.times { zones << last_price }

    logger.info zones.map { |i| i.round(2) }
    logger.info "\n"

    quotes.order(:date).each do |quote|

      price = quote[:open]

      # Cut loss when a price is lower than 0.30 OR the portfolio losses more than 10%
      if price <= 0.30 or (pl / cost.to_f) <= -0.10
        unless zones.empty?
          while not zones.empty?
            bought_price = zones.pop
            bought = (bought_price * vol) + (bought_price * vol * fee)
            sold = (price * vol) - (price * vol * fee)
            _pl = sold - bought
            pl += _pl
            dd += _pl if _pl < 0
            cost += bought
            lowest_price = price
          end
          sum_reseted_cost += cost
          sum_reseted_pl += pl
          sum_reseted_dd += dd
          cost = 0
          pl = 0
          dd = 0

          logger.debug "Date   : #{quote[:date].strftime('%Y-%m-%d')}"
          logger.debug "Lowest : #{'%.2f' % lowest_price}"
          logger.debug "----------------------- Summer Sale !!!\n\n"
        end

        next if price <= 0.30
      end

      # Revive when it shows strong uptrend after cut loss
      if sum_reseted_cost > 0
        lowest_price = price if price < lowest_price
        next if price <= lowest_price + 0.15
      end

      if quote[:open] < quote[:close]
        while price <= quote[:close] do
          if price >= entry_price(lowest_price)
            if zones.size < zone_size
              highest_price = price if zones.empty?

              zones.unshift(price)

              logger.debug "Date   : #{quote[:date].strftime('%Y-%m-%d')}"
              logger.debug "Lowest : #{'%.2f' % lowest_price}"
              logger.debug "Bought : #{'%.2f' % price}"
              logger.debug "%Diff  : #{'%.2f' % ((price - lowest_price) / lowest_price * 100)}%\n"

              logger.info quote[:date].strftime('%Y-%m-%d')
              logger.info zones.map { |i| i.round(2) }
              logger.info "\n"
            end
          elsif price <= exit_price(highest_price)
            unless zones.empty?
              lowest_price = price if zones.size == 1

              bought_price = zones.pop
              bought = (bought_price * vol) + (bought_price * vol * fee)
              sold = (price * vol) - (price * vol * fee)
              _pl = sold - bought
              pl += _pl
              dd += _pl if _pl < 0
              cost += bought

              logger.debug "Date   : #{quote[:date].strftime('%Y-%m-%d')}"
              logger.debug "Highest: #{'%.2f' % highest_price}"
              logger.debug "Price  : #{'%.2f' % price}"
              logger.debug "%Diff  : #{'%.2f' % ((price - highest_price) / highest_price * 100)}%"
              logger.debug "Bought : #{'%.2f' % bought_price}"
              logger.debug "%P/L   : #{'%.2f' % ((sold - bought) / bought * 100)}%\n"

              logger.info quote[:date].strftime('%Y-%m-%d')
              logger.info zones.map { |i| i.round(2) }
              logger.info "\n"
            end
          end
          price += spread
        end

      elsif quote[:open] > quote[:close]
        while price >= quote[:close] do
          if price >= entry_price(lowest_price)
            if zones.size < zone_size
              highest_price = price if zones.empty?

              zones.unshift(price)

              logger.debug "Date   : #{quote[:date].strftime('%Y-%m-%d')}"
              logger.debug "Lowest : #{'%.2f' % lowest_price}"
              logger.debug "Bought : #{'%.2f' % price}"
              logger.debug "%Diff  : #{'%.2f' % ((price - lowest_price) / lowest_price * 100)}%\n"

              logger.info quote[:date].strftime('%Y-%m-%d')
              logger.info zones.map { |i| i.round(2) }
              logger.info "\n"
            end
          elsif price <= exit_price(highest_price)
            unless zones.empty?
              lowest_price = price if zones.size == 1

              bought_price = zones.pop
              bought = (bought_price * vol) + (bought_price * vol * fee)
              sold = (price * vol) - (price * vol * fee)
              _pl = sold - bought
              pl += _pl
              dd += _pl if _pl < 0
              cost += bought

              logger.debug "Date   : #{quote[:date].strftime('%Y-%m-%d')}"
              logger.debug "Highest: #{'%.2f' % highest_price}"
              logger.debug "Price  : #{'%.2f' % price}"
              logger.debug "%Diff  : #{'%.2f' % ((price - highest_price) / highest_price * 100)}%"
              logger.debug "Bought : #{'%.2f' % bought_price}"
              logger.debug "%P/L   : #{'%.2f' % ((sold - bought) / bought * 100)}%\n"

              logger.info quote[:date].strftime('%Y-%m-%d')
              logger.info zones.map { |i| i.round(2) }
              logger.info "\n"
            end
          end
          price -= spread
        end
      else
        if price >= entry_price(lowest_price)
          if zones.size < zone_size
            highest_price = price if zones.empty?

            zones.unshift(price)

            logger.debug "Date   : #{quote[:date].strftime('%Y-%m-%d')}"
            logger.debug "Lowest : #{'%.2f' % lowest_price}"
            logger.debug "Bought : #{'%.2f' % price}"
            logger.debug "%Diff  : #{'%.2f' % ((price - lowest_price) / lowest_price * 100)}%\n"

            logger.info quote[:date].strftime('%Y-%m-%d')
            logger.info zones.map { |i| i.round(2) }
            logger.info "\n"
          end
        elsif price <= exit_price(highest_price)
          unless zones.empty?
            lowest_price = price if zones.size == 1

            bought_price = zones.pop
            bought = (bought_price * vol) + (bought_price * vol * fee)
            sold = (price * vol) - (price * vol * fee)
            _pl = sold - bought
            pl += _pl
            dd += _pl if _pl < 0
            cost += bought

            logger.debug "Date   : #{quote[:date].strftime('%Y-%m-%d')}"
            logger.debug "Highest: #{'%.2f' % highest_price}"
            logger.debug "Price  : #{'%.2f' % price}"
            logger.debug "%Diff  : #{'%.2f' % ((price - highest_price) / highest_price * 100)}%"
            logger.debug "Bought : #{'%.2f' % bought_price}"
            logger.debug "%P/L   : #{'%.2f' % ((sold - bought) / bought * 100)}%\n"

            logger.info quote[:date].strftime('%Y-%m-%d')
            logger.info zones.map { |i| i.round(2) }
            logger.info "\n"
          end
        end
      end

      highest_price = price if price > highest_price
      lowest_price = price if price < lowest_price
    end

    # Last trading day
    while not zones.empty?
      bought_price = zones.pop
      bought = (bought_price * vol) + (bought_price * vol * fee)
      sold = (price * vol) - (price * vol * fee)
      _pl = sold - bought
      pl += _pl
      dd += _pl if _pl < 0
      cost += bought
    end

    logger.warn "---------------------------------------"
    logger.warn "Symbol  : #{symbol}"
    if sum_reseted_cost > 0
      cost += sum_reseted_cost
      pl += sum_reseted_pl
      dd += sum_reseted_dd
    end
    logger.warn "Cost    : #{'%.2f' % cost}"
    logger.warn "Profit  : #{'%.2f' % pl} (#{'%.2f' % (pl / cost * 100)}%)"
    logger.warn "Drawdown: #{'%.2f' % dd} (#{'%.2f' % (dd / cost * 100)}%)"
    logger.warn "Last    : #{'%.2f' % price}"
  end

  def self.entry_price(lowest_price)
    lowest_price + 0.05
  end

  def self.exit_price(highest_price)
    highest_price - 0.15
  end
end
