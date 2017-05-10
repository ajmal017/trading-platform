module Strategy

  class OneMa
    def initialize(historical_data, ma_type=:sma, period=10)
      @historical_data = historical_data
      @ma_type = ma_type
      @period = period
    end

    def run
      ma = Indicator.create(@ma_type, @period).run(@historical_data)
      ma_sold = true

      @historical_data.each_with_index do |price, idx|
        begin
          if ma_sold and price[:open] <= price[:close] and price[:open] >= ma[idx]
            ma_sold = false
            signal = {:side => 'B', :date => price[:date], :price => price[:close]}
            yield signal
          elsif ma_sold and price[:open] <= ma[idx] and price[:close] > ma[idx]
            ma_sold = false
            signal = {:side => 'B', :date => price[:date], :price => ma[idx].round(2)}
            yield signal
          elsif not ma_sold and price[:open] < ma[idx]
            ma_sold = true
            signal = {:side => 'S', :date => price[:date], :price => price[:open]}
            yield signal
          elsif not ma_sold and price[:open] >= ma[idx] and price[:close] < ma[idx]
            ma_sold = true
            signal = {:side => 'S', :date => price[:date], :price => ma[idx].round(2)}
            yield signal
          end
        rescue
          next
        end
      end
    end
  end

end
