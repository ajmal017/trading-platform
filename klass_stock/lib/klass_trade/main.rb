require 'date'
require 'logger'

require 'indicator'

require_relative '../../app/models/deal_handler'
require_relative '../../app/services/price_spread'

require_relative './strategy/base'
require_relative './strategy/spread'
require_relative './strategy/zone'
require_relative './strategy/moving_average'


module KlassTrade

  class Main

    def self.run(conn, strategies=[])
      buys = []
      sells = []

      if strategies.include? 's0'
        securities = []
        conn.exec("SELECT * FROM pre_orders WHERE active = 't'") do |r|
          r.each {|row| securities << row}
        end

        securities.each do |security|
          id = security['id'].to_i
          symbol = security['symbol']
          side = security['side']
          price = security['price'].to_f
          volume = security['volume'].to_i

          bid_price = 0
          offer_price = 0
          conn.exec("SELECT * FROM intraday_quotes WHERE symbol = $1 AND datetime >= $2
                     ORDER BY datetime DESC LIMIT 1", [symbol, Date.today]) do |r|
            r.each { |row|
              bid_price = row['bid_price'].to_f
              offer_price = row['offer_price'].to_f
            }
          end

          if side == 'B' and price == offer_price
            buys << {side: side, symbol: symbol, price: price, volume: volume}
            conn.exec("UPDATE pre_orders SET active = 'f' WHERE id = $1", [id])
            Strategy::Base.logger "PRE-ORDER: B, #{symbol}, #{'%.2f' % price}, #{volume}"
          elsif side == 'S' and price == bid_price
            sells << {side: side, symbol: symbol, price: price, volume: volume}
            conn.exec("UPDATE pre_orders SET active = 'f' WHERE id = $1", [id])
            Strategy::Base.logger "PRE-ORDER: S, #{symbol}, #{'%.2f' % price}, #{volume}"
          end
        end
      end

      if strategies.include? 's1'
        securities = []
        conn.exec("SELECT symbol FROM monitored_securities WHERE active = 't' AND s1 = 't'") do |r|
          r.each {|row| securities << row}
        end

        securities.each do |security|
          symbol = security['symbol']
          buy = buys.find {|b| b[:symbol] == symbol}
          unless buy
            buy = {side: 'B', symbol: symbol, price: 0, volume: 0}
            buys << buy
          end
          sell = sells.find {|s| s[:symbol] == symbol}
          unless sell
            sell = {side: 'S', symbol: symbol, price: 0, volume: 0}
            sells << sell
          end
          Strategy::Spread.run(conn, symbol) do |signals|
            signals.each do |signal|
              if signal[:side] == 'B'
                buy[:price] = signal[:price]
                buy[:volume] += signal[:volume]
              elsif signal[:side] == 'S'
                sell[:price] = signal[:price]
                sell[:volume] += signal[:volume]
              end
            end
          end
        end
      end

      if strategies.include? 's2'
        securities = []
        conn.exec("SELECT symbol FROM monitored_securities WHERE active = 't' AND s2 = 't'") do |r|
          r.each {|row| securities << row}
        end

        securities.each do |security|
          symbol = security['symbol']
          buy = buys.find {|b| b[:symbol] == symbol}
          unless buy
            buy = {side: 'B', symbol: symbol, price: 0, volume: 0}
            buys << buy
          end
          sell = sells.find {|s| s[:symbol] == symbol}
          unless sell
            sell = {side: 'S', symbol: symbol, price: 0, volume: 0}
            sells << sell
          end
          Strategy::Zone.run(conn, symbol) do |signals|
            signals.each do |signal|
              if signal[:side] == 'B'
                buy[:price] = signal[:price]
                buy[:volume] += signal[:volume]
              elsif signal[:side] == 'S'
                sell[:price] = signal[:price]
                sell[:volume] += signal[:volume]
              end
            end
          end
        end
      end

      if strategies.include? 's3'
        securities = []
        conn.exec("SELECT symbol FROM monitored_securities WHERE active = 't' AND s3 = 't'") do |r|
          r.each {|row| securities << row}
        end

        securities.each do |security|
          symbol = security['symbol']
          buy = buys.find {|b| b[:symbol] == symbol}
          unless buy
            buy = {side: 'B', symbol: symbol, price: 0, volume: 0}
            buys << buy
          end
          sell = sells.find {|s| s[:symbol] == symbol}
          unless sell
            sell = {side: 'S', symbol: symbol, price: 0, volume: 0}
            sells << sell
          end
          Strategy::MovingAverage.run(conn, symbol) do |signals|
            signals.each do |signal|
              if signal[:side] == 'B'
                buy[:price] = signal[:price]
                buy[:volume] += signal[:volume]
              elsif signal[:side] == 'S'
                sell[:price] = signal[:price]
                sell[:volume] += signal[:volume]
              end
            end
          end
        end
      end

      buys.each {|buy| yield buy if buy[:volume] > 0}
      sells.each {|sell| yield sell if sell[:volume] > 0}
    end

  end

end
