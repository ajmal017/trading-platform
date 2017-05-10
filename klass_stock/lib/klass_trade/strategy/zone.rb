module Strategy

  class Zone < Strategy::Base

    def self.run(conn, symbol)
      signals = []
      # etf = %w{EBANK ECOMM EFOOD EICT ENY}.include? symbol
      etf = false

      bid_price = 0
      offer_price = 0
      conn.exec("SELECT * FROM intraday_quotes WHERE symbol = $1 AND datetime >= $2
                 ORDER BY datetime DESC LIMIT 1", [symbol, Date.today]) do |r|
        r.each { |row|
          bid_price = row['bid_price'].to_f
          offer_price = row['offer_price'].to_f
        }
      end
      return nil if bid_price <= 0 or offer_price <= 0 or
                   (bid_price + PriceSpread.for(bid_price, etf)).round(2) != offer_price

      zone = nil
      conn.exec("SELECT * FROM zone_trades WHERE symbol = $1 LIMIT 1", [symbol]) do |r|
        r.each {|row| zone = row}
      end
      if zone
        if zone['active'].nil? or zone['active'] == 'f'
          conn.exec("UPDATE zone_trades SET active = 't' WHERE symbol = $1", [symbol])
        end
      else
        conn.exec("INSERT INTO zone_trades (symbol) VALUES ($1)", [symbol])
        conn.exec("SELECT * FROM zone_trades WHERE symbol = $1 LIMIT 1", [symbol]) do |r|
          r.each {|row| zone = row}
        end
      end
      volume = zone['volume'].to_i
      available = zone['available'].to_i
      ref_sell = zone['ref_sell'].to_f
      up_sell = 3
      down_sell = 3
      min_profit = 20

      up_sell_point = (ref_sell + (PriceSpread.for(ref_sell, etf) * up_sell)).round(2)
      down_sell_point = (ref_sell - (PriceSpread.for(ref_sell, etf) * down_sell)).round(2)

      # Up sell
      if available > 0 and bid_price >= up_sell_point
        _profit = profit(conn, symbol, bid_price, volume)
        if _profit > min_profit
          signals << {side: 'S', price: bid_price, volume: volume}
          available -= volume
          conn.exec("UPDATE zone_trades SET available = $1, ref_sell = $2 WHERE symbol = $3",
                    [available, bid_price, symbol])
          logger "ZONE: US, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
        else
          _price = (bid_price - (PriceSpread.for(bid_price, etf) * (up_sell - 1))).round(2)
          conn.exec("UPDATE zone_trades SET ref_sell = $1 WHERE symbol = $2", [_price, symbol])
          logger "ZONE: -US, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
        end

      # Down sell
      elsif available > 0 and bid_price <= down_sell_point
        _profit = profit(conn, symbol, bid_price, volume)
        if _profit > min_profit
          signals << {side: 'S', price: bid_price, volume: volume}
          available -= volume
          conn.exec("UPDATE zone_trades SET available = $1, ref_sell = $2 WHERE symbol = $3",
                    [available, bid_price, symbol])
          logger "ZONE: DS, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
        else
          conn.exec("UPDATE zone_trades SET ref_sell = $1 WHERE symbol = $2", [bid_price, symbol])
          logger "ZONE: -DS, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
        end
      end

      yield signals unless signals.empty?
    end

  end

end
