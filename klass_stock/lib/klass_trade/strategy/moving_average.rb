module Strategy

  class MovingAverage < Strategy::Base

    def self.run(conn, symbol)
      historical_data = []
      signals = []
      # etf = %w{EBANK ECOMM EFOOD EICT ENY}.include? symbol
      etf = false

      bid_price = 0
      offer_price = 0
      conn.exec("SELECT * FROM intraday_quotes WHERE symbol = $1 AND datetime >= $2
                 ORDER BY datetime DESC LIMIT 1",
                [symbol, Date.today]) do |r|
        r.each { |row|
          bid_price = row['bid_price'].to_f
          offer_price = row['offer_price'].to_f
        }
      end
      return nil if bid_price <= 0 or offer_price <= 0 or
                   (bid_price + PriceSpread.for(bid_price, etf)).round(2) != offer_price

      conn.exec("SELECT * FROM quotes WHERE symbol = $1 AND date >= $2 ORDER BY date",
                [symbol, (Date.today - 50)]) do |r|
        r.each do |row|
          if row['close'].to_f > 0
            _close = ((row['high'].to_f + row['low'].to_f + row['close'].to_f) / 3.0).round(2)
            historical_data << {close: _close}
          end
        end
      end
      return nil if historical_data.empty?

      historical_data << {close: bid_price}
      ma_type = :ema
      ma0 = Indicator.create(ma_type, 5).run(historical_data).reverse
      ma1 = Indicator.create(ma_type, 10).run(historical_data).reverse
      ma2 = Indicator.create(ma_type, 15).run(historical_data).reverse
      ma3 = Indicator.create(ma_type, 20).run(historical_data).reverse
      ma4 = Indicator.create(ma_type, 25).run(historical_data).reverse
      ma5 = Indicator.create(ma_type, 30).run(historical_data).reverse

      fraction = nil
      conn.exec("SELECT * FROM fraction_trades WHERE symbol = $1 LIMIT 1", [symbol]) do |r|
        r.each {|row| fraction = row}
      end
      if fraction
        if fraction['active'].nil? or fraction['active'] == 'f'
          conn.exec("UPDATE fraction_trades SET active = 't' WHERE symbol = $1", [symbol])
        end
      else
        conn.exec("INSERT INTO fraction_trades (symbol) VALUES ($1)", [symbol])
        conn.exec("SELECT * FROM fraction_trades WHERE symbol = $1 LIMIT 1", [symbol]) do |r|
          r.each {|row| fraction = row}
        end
      end
      volume = fraction['volume'].to_i
      f1 = fraction['f1']
      f2 = fraction['f2']
      f3 = fraction['f3']
      f4 = fraction['f4']
      f5 = fraction['f5']

      min_profit = 20

      buy = {side: 'B', price: offer_price, volume: volume}
      sell = {side: 'S', price: bid_price, volume: volume}

      ma0[0] = ma0[0].round(2) rescue 0
      ma0[1] = ma0[1].round(2) rescue 0
      if ma1[1]
        if ma0[0] > ma0[1] and ma0[0] > ma1[0].round(2) and ma0[1] > ma1[1].round(2) and
              (f1.nil? or f1 == 'f')
          signals << buy
          conn.exec("UPDATE fraction_trades SET f1 = 't' WHERE symbol = $1", [symbol])
          logger "MA1: B, #{symbol}, #{'%.2f' % offer_price}, #{volume}"
        elsif ma0[0] < ma1[0].round(2) and f1 == 't'
          _profit = profit(conn, symbol, bid_price, volume)
          if _profit > min_profit
            signals << sell
            conn.exec("UPDATE fraction_trades SET f1 = NULL WHERE symbol = $1", [symbol])
            logger "MA1: S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          else
            logger "MA1: -S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          end
        end
      end

      if ma2[1]
        if ma0[0] > ma0[1] and ma0[0] > ma2[0].round(2) and ma0[1] > ma2[1].round(2) and
              (f2.nil? or f2 == 'f')
          signals << buy
          conn.exec("UPDATE fraction_trades SET f2 = 't' WHERE symbol = $1", [symbol])
          logger "MA2: B, #{symbol}, #{'%.2f' % offer_price}, #{volume}"
        elsif ma0[0] < ma2[0].round(2) and f2 == 't'
          _profit = profit(conn, symbol, bid_price, volume)
          if _profit > min_profit
            signals << sell
            conn.exec("UPDATE fraction_trades SET f2 = NULL WHERE symbol = $1", [symbol])
            logger "MA2: S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          else
            logger "MA2: -S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          end
        end
      end

      if ma3[1]
        if ma0[0] > ma0[1] and ma0[0] > ma3[0].round(2) and ma0[1] > ma3[1].round(2) and
              (f3.nil? or f3 == 'f')
          signals << buy
          conn.exec("UPDATE fraction_trades SET f3 = 't' WHERE symbol = $1", [symbol])
          logger "MA3: B, #{symbol}, #{'%.2f' % offer_price}, #{volume}"
        elsif ma0[0] < ma3[0].round(2) and f3 == 't'
          _profit = profit(conn, symbol, bid_price, volume)
          if _profit > min_profit
            signals << sell
            conn.exec("UPDATE fraction_trades SET f3 = NULL WHERE symbol = $1", [symbol])
            logger "MA3: S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          else
            logger "MA3: -S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          end
        end
      end

      if ma4[1]
        if ma0[0] > ma0[1] and ma0[0] > ma4[0].round(2) and ma0[1] > ma4[1].round(2) and
              (f4.nil? or f4 == 'f')
          signals << buy
          conn.exec("UPDATE fraction_trades SET f4 = 't' WHERE symbol = $1", [symbol])
          logger "MA4: B, #{symbol}, #{'%.2f' % offer_price}, #{volume}"
        elsif ma0[0] < ma4[0].round(2) and f4 == 't'
          _profit = profit(conn, symbol, bid_price, volume)
          if _profit > min_profit
            signals << sell
            conn.exec("UPDATE fraction_trades SET f4 = NULL WHERE symbol = $1", [symbol])
            logger "MA4: S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          else
            logger "MA4: -S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          end
        end
      end

      if ma5[1]
        if ma0[0] > ma0[1] and ma0[0] > ma5[0].round(2) and ma0[1] > ma5[1].round(2) and
              (f5.nil? or f5 == 'f')
          signals << buy
          conn.exec("UPDATE fraction_trades SET f5 = 't' WHERE symbol = $1", [symbol])
          logger "MA5: B, #{symbol}, #{'%.2f' % offer_price}, #{volume}"
        elsif ma0[0] < ma5[0].round(2) and f5 == 't'
          _profit = profit(conn, symbol, bid_price, volume)
          if _profit > min_profit
            signals << sell
            conn.exec("UPDATE fraction_trades SET f5 = NULL WHERE symbol = $1", [symbol])
            logger "MA5: S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          else
            logger "MA5: -S, #{symbol}, #{'%.2f' % bid_price}, #{volume} (#{'%.2f' % _profit.round(2)})"
          end
        end
      end

      yield signals unless signals.empty?
    end

  end

end
