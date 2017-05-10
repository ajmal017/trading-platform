require 'indicator'

class ChartsController < ApplicationController

  def index
    @set50_stocks = Stock.set50
    @set100_stocks = Stock.set100
    @sethd_stocks = Stock.sethd
  end

  def show
    symbol = params[:symbol].upcase
    if Stock.where(:symbol => symbol).first
      @company = Stock.where(:symbol => symbol).first.company
    elsif Warrant.where(:symbol => symbol).first
      @company = Warrant.where(:symbol => symbol).first.company
    elsif DerivativeWarrant.where(:symbol => symbol).first
      @company = DerivativeWarrant.where(:symbol => symbol).first.company
    elsif ETF.where(:symbol => symbol).first
      @company = ETF.where(:symbol => symbol).first
    end

    if @company
      quote = Quote.where(:symbol => symbol).limit(1).first
      return redirect_to charts_path unless quote
    else
      return redirect_to charts_path
    end

    @symbol = symbol
    respond_to do |format|
      format.html { render :show, :layout => 'chart' }
      format.json do
        from_date = params[:from_date]
        to_date = params[:to_date]
        _quotes = Quote.where("symbol = ?", symbol)
        if from_date && to_date
          _quotes = _quotes.where("date >= ? AND date <= ?", from_date, to_date)
        elsif from_date
          _quotes = _quotes.where("date >= ?", from_date)
        elsif to_date
          _quotes = _quotes.where("date <= ?", to_date)
        else
          _quotes = _quotes.where("date >= ?", Date.today - 1.year)
        end

        historical_data = []
        quotes = []
        ma0 = []
        ma1 = []
        bbands_upper = []
        bbands_middle = []
        bbands_lower = []
        # macd = []
        # macd_signal = []
        # macd_histogram = []
        # adx = []
        # plus_di = []
        # minus_di = []

        _quotes.order(:date).each do |q|
          historical_data << {
            :date => q.date,
            :open => q.open,
            :high => q.high,
            :low => q.low,
            :close => q.close,
            :hlc => ((q.high + q.low + q.close) / 3.0).round(2),
            :volume => q.volume
          }
          if request.host =~ /localhost/
            date = (q.date.to_time.to_i + (7*60*60)) * 1000
          else
            date = q.date.to_time.to_i * 1000
          end
          quotes << [date, q.open, q.high, q.low, q.close, q.volume]
          ma0 << [date]
          ma1 << [date]
          bbands_upper << [date]
          bbands_middle << [date]
          bbands_lower << [date]
          # macd << [date]
          # macd_signal << [date]
          # macd_histogram << [date]
          # adx << [date]
          # plus_di << [date]
          # minus_di << [date]
        end

        last = historical_data.last
        q = SETScraper.new.get_real_time_price(symbol, true)
        if q[:open] and q[:open] > 0 and q[:high] > 0 and q[:low] > 0 and q[:last] > 0 and
              (q[:open] != last[:open] or q[:high] != last[:high] or q[:low] != last[:low])
          historical_data << {
            :date => q[:last_update],
            :open => q[:open],
            :high => q[:high],
            :low => q[:low],
            :close => q[:last],
            :hlc => ((q[:high] + q[:low] + q[:last]) / 3.0).round(2),
            :volume => q[:volume]
          }

          date = q[:last_update].to_time.to_i * 1000
          quotes << [date, q[:open], q[:high], q[:low], q[:last], q[:volume]]
          ma0 << [date]
          ma1 << [date]
          bbands_upper << [date]
          bbands_middle << [date]
          bbands_lower << [date]
          # macd << [date]
          # macd_signal << [date]
          # macd_histogram << [date]
          # adx << [date]
          # plus_di << [date]
          # minus_di << [date]
        end

        indi = Indicator.create(:wma, 10)
        indi.default_getter = :open
        outputs = indi.run historical_data
        outputs.each_with_index do |data, index|
          ma0[index] << data
        end

        indi = Indicator.create(:wma, 10)
        indi.default_getter = :close
        outputs = indi.run historical_data
        outputs.each_with_index do |data, index|
          ma1[index] << data
        end

        indi = Indicator.create(:bbands, 20)
        indi.default_getter = :hlc
        outputs = indi.run historical_data
        outputs[:out_real_upper_band].each_with_index do |data, index|
          bbands_upper[index] << data
        end
        outputs[:out_real_middle_band].each_with_index do |data, index|
          bbands_middle[index] << data
        end
        outputs[:out_real_lower_band].each_with_index do |data, index|
          bbands_lower[index] << data
        end

        # outputs = Indicator.create(:macd).run(historical_data)
        # outputs[:out_macd].each_with_index do |data, index|
        #   macd[index] << data
        # end
        # outputs[:out_macd_signal].each_with_index do |data, index|
        #   macd_signal[index] << data
        # end
        # outputs[:out_macd_hist].each_with_index do |data, index|
        #   macd_histogram[index] << data
        # end

        # outputs = Indicator.create(:adx).run(historical_data)
        # outputs.each_with_index do |data, index|
        #   adx[index] << data
        # end
        # outputs = Indicator.create(:plusdi).run(historical_data)
        # outputs.each_with_index do |data, index|
        #   plus_di[index] << data
        # end
        # outputs = Indicator.create(:minusdi).run(historical_data)
        # outputs.each_with_index do |data, index|
        #   minus_di[index] << data
        # end

        render :json => {
          :quotes => quotes,
          :ma0 => ma0,
          :ma1 => ma1,
          :bbands_upper => bbands_upper,
          :bbands_middle => bbands_middle,
          :bbands_lower => bbands_lower,
          # :macd => macd,
          # :macd_signal => macd_signal,
          # :macd_histogram => macd_histogram,
          # :adx => adx,
          # :plus_di => plus_di,
          # :minus_di => minus_di
        }.to_json
      end
    end
  end

end
