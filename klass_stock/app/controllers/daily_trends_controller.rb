require 'indicator/mixin'

class DailyTrendsController < ApplicationController
  def index
    date = params[:date] ? Date.strptime(params[:date], '%Y%m%d') : Date.today

    @uptrends = []
    @downtrends = []
    @sideways = []

    Stock.set50.each do |stock|
      historical_data = []
      quotes = Quote.where("symbol = ? and date >= ? and date <= ?",
                           stock.symbol, date - 6.months, date)
                    .order(:date)
      quotes.each do |q|
        historical_data << {
          :date => q.date,
          :open => q.open,
          :high => q.high,
          :low => q.low,
          :close => q.close
        }
      end
      @date = quotes.last.date unless @date

      trend = get_trend(historical_data)
      case trend[:trend]
      when 'up'
        @uptrends << trend.update(:symbol => stock.symbol)
      when 'down'
        @downtrends << trend.update(:symbol => stock.symbol)
      when 'sideway'
        @sideways << trend.update(:symbol => stock.symbol)
      end
    end
  end

  private

  def get_trend(historical_data, ma_type=:ema)
    trend = {}
    trend[:trend] = 'sideway'

    ma0 = Indicator.create(ma_type, 5).run(historical_data).reverse
    ma1 = Indicator.create(ma_type, 10).run(historical_data).reverse
    ma2 = Indicator.create(ma_type, 20).run(historical_data).reverse
    ma3 = Indicator.create(ma_type, 45).run(historical_data).reverse

    trend[:ma] = {'MA05' => ma0[0].round(2),
                  'MA10' => ma1[0].round(2),
                  'MA20' => ma2[0].round(2),
                  'MA45' => ma3[0].round(2)}.sort_by { |k, v| v.to_f }.reverse

    if ma0[1] > ma0[0] && ma1[1] > ma1[0]
      trend[:trend] = 'down'
    elsif ma0[1] < ma0[0] && ma1[1] < ma1[0]
      trend[:trend] = 'up'
    end

    trend
  end
end
