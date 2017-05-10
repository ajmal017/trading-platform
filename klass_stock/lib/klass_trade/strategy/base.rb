module Strategy

  class Base
    def self.logger(msg)
      lg = Logger.new(STDOUT)
      lg.formatter = proc {|severity, datetime, progname, msg| "#{msg}\n"}
      now = Time.now.utc + 25200
      lg.debug "#{'%.2d' % now.hour}:#{'%.2d' % now.min}:#{'%.2d' % now.sec} - #{msg}"
    end

    def self.profit(conn, symbol, price, volume, portfolio_id=1)
      sum_volume = 0
      sum_price = 0
      conn.exec("SELECT * FROM in_hand_securities WHERE portfolio_id = $1 AND symbol = $2 LIMIT 1",
                [portfolio_id, symbol]) do |r|
        r.each { |row|
          sum_volume = row['sum_volume'].to_i
          sum_price = row['sum_price'].to_f
        }
      end
      return 0 unless sum_volume > 0
      avg_price = (sum_price / sum_volume).round(2)
      DealHandler.calculate_realized_pl(avg_price, price, volume)
    end
    def self.profit?(conn, symbol, price, volume, portfolio_id=1)
      profit(conn, symbol, price, volume, portfolio_id) > 0
    end
  end

end
