module Strategy

  class Spread < Strategy::Base

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

      step = nil
      conn.exec("SELECT * FROM step_trades WHERE symbol = $1 LIMIT 1", [symbol]) do |r|
        r.each {|row| step = row}
      end
      if step
        if step['active'].nil? or step['active'] == 'f'
          conn.exec("UPDATE step_trades SET active = 't' WHERE symbol = $1", [symbol])
        end
      else
        conn.exec("INSERT INTO step_trades (symbol) VALUES ($1)", [symbol])
        conn.exec("SELECT * FROM step_trades WHERE symbol = $1 LIMIT 1", [symbol]) do |r|
          r.each {|row| step = row}
        end
      end
      volume = step['volume'].to_i
      max_step = step['max_step'].to_i
      current_step = step['current_step'].to_i
      ref_buy = step['ref_buy'].to_f
      ref_sell = step['ref_sell'].to_f
      spread_up = 10
      spread_down = 5
      min_profit = 20

      if ref_buy == 0
        _price = (offer_price - (PriceSpread.for(offer_price, etf) * (spread_up - 1))).round(2)
        conn.exec("UPDATE step_trades SET ref_buy = $1 WHERE symbol = $2", [_price, symbol])
        return nil
      end

      buy_point = (ref_buy + (PriceSpread.for(ref_buy, etf) * spread_up)).round(2)
      sell_point = (ref_sell - (PriceSpread.for(ref_sell, etf) * spread_down)).round(2)

      if current_step < max_step and offer_price >= buy_point
        vol = volume * spread_up
        signals << {side: 'B', price: offer_price, volume: vol}
        current_step += spread_up
        conn.exec("UPDATE step_trades SET current_step = $1, ref_buy = $2, ref_sell = $3
                   WHERE symbol = $4", [current_step, offer_price, bid_price, symbol])
        logger "SPREAD: B, #{symbol}, #{'%.2f' % offer_price}, #{vol}"

      elsif current_step > 0 and bid_price <= sell_point
        _profit = profit(conn, symbol, bid_price, volume)
        if _profit > min_profit
          signals << {side: 'S', price: bid_price, volume: volume}
          current_step -= 1
          conn.exec("UPDATE step_trades SET current_step = $1, ref_buy = $2, ref_sell = $3
                     WHERE symbol = $4", [current_step, offer_price, bid_price, symbol])
          logger "SPREAD: S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
        else
          conn.exec("UPDATE step_trades SET ref_buy = $1, ref_sell = $2 WHERE symbol = $3",
                    [offer_price, bid_price, symbol])
          logger "SPREAD: -S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
        end
        ref_buy = offer_price
      end

      yield signals unless signals.empty?

      if offer_price < ref_buy
        conn.exec("UPDATE step_trades SET ref_buy = $1 WHERE symbol = $2", [offer_price, symbol])
      elsif current_step == max_step and bid_price > ref_sell
        conn.exec("UPDATE step_trades SET ref_sell = $1 WHERE symbol = $2", [bid_price, symbol])
      end
    end

  end

end
