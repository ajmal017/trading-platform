module Strategy

  class FiveMaRider
    def initialize(historical_data, ma_type=:sma)
      @historical_data = historical_data
      @ma_type = ma_type
    end

    def run
      ma1 = Indicator.create(@ma_type, 20).run(@historical_data)
      ma2 = Indicator.create(@ma_type, 45).run(@historical_data)
      ma3 = Indicator.create(@ma_type, 70).run(@historical_data)
      ma4 = Indicator.create(@ma_type, 95).run(@historical_data)
      ma5 = Indicator.create(@ma_type, 120).run(@historical_data)

      ma1_sold = true
      ma2_sold = true
      ma3_sold = true
      ma4_sold = true
      ma5_sold = true

      @historical_data.each_with_index do |price, idx|
        begin
          if ma1_sold and price[:open] <= price[:close] and price[:open] >= ma1[idx]
            ma1_sold = false
            signal = {:side => 'B', :date => price[:date], :price => price[:close]}
            yield signal
          elsif ma1_sold and price[:open] <= ma1[idx] and price[:close] > ma1[idx]
            ma1_sold = false
            signal = {:side => 'B', :date => price[:date], :price => ma1[idx].round(2)}
            yield signal
          elsif not ma1_sold and price[:open] < ma1[idx]
            ma1_sold = true
            signal = {:side => 'S', :date => price[:date], :price => price[:open]}
            yield signal
          elsif not ma1_sold and price[:open] >= ma1[idx] and price[:close] < ma1[idx]
            ma1_sold = true
            signal = {:side => 'S', :date => price[:date], :price => ma1[idx].round(2)}
            yield signal
          end

          if ma2_sold and price[:open] <= price[:close] and price[:open] >= ma2[idx]
            ma2_sold = false
            signal = {:side => 'B', :date => price[:date], :price => price[:close]}
            yield signal
          elsif ma2_sold and price[:open] <= ma2[idx] and price[:close] > ma2[idx]
            ma2_sold = false
            signal = {:side => 'B', :date => price[:date], :price => ma2[idx].round(2)}
            yield signal
          elsif not ma2_sold and price[:open] < ma2[idx]
            ma2_sold = true
            signal = {:side => 'S', :date => price[:date], :price => price[:open]}
            yield signal
          elsif not ma2_sold and price[:open] >= ma2[idx] and price[:close] < ma2[idx]
            ma2_sold = true
            signal = {:side => 'S', :date => price[:date], :price => ma2[idx].round(2)}
            yield signal
          end

          if ma3_sold and price[:open] <= price[:close] and price[:open] >= ma3[idx]
            ma3_sold = false
            signal = {:side => 'B', :date => price[:date], :price => price[:close]}
            yield signal
          elsif ma3_sold and price[:open] <= ma3[idx] and price[:close] > ma3[idx]
            ma3_sold = false
            signal = {:side => 'B', :date => price[:date], :price => ma3[idx].round(2)}
            yield signal
          elsif not ma3_sold and price[:open] < ma3[idx]
            ma3_sold = true
            signal = {:side => 'S', :date => price[:date], :price => price[:open]}
            yield signal
          elsif not ma3_sold and price[:open] >= ma3[idx] and price[:close] < ma3[idx]
            ma3_sold = true
            signal = {:side => 'S', :date => price[:date], :price => ma3[idx].round(2)}
            yield signal
          end

          if ma4_sold and price[:open] <= price[:close] and price[:open] >= ma4[idx]
            ma4_sold = false
            signal = {:side => 'B', :date => price[:date], :price => price[:close]}
            yield signal
          elsif ma4_sold and price[:open] <= ma4[idx] and price[:close] > ma4[idx]
            ma4_sold = false
            signal = {:side => 'B', :date => price[:date], :price => ma4[idx].round(2)}
            yield signal
          elsif not ma4_sold and price[:open] < ma4[idx]
            ma4_sold = true
            signal = {:side => 'S', :date => price[:date], :price => price[:open]}
            yield signal
          elsif not ma4_sold and price[:open] >= ma4[idx] and price[:close] < ma4[idx]
            ma4_sold = true
            signal = {:side => 'S', :date => price[:date], :price => ma4[idx].round(2)}
            yield signal
          end

          if ma5_sold and price[:open] <= price[:close] and price[:open] >= ma5[idx]
            ma5_sold = false
            signal = {:side => 'B', :date => price[:date], :price => price[:close]}
            yield signal
          elsif ma5_sold and price[:open] <= ma5[idx] and price[:close] > ma5[idx]
            ma5_sold = false
            signal = {:side => 'B', :date => price[:date], :price => ma5[idx].round(2)}
            yield signal
          elsif not ma5_sold and price[:open] < ma5[idx]
            ma5_sold = true
            signal = {:side => 'S', :date => price[:date], :price => price[:open]}
            yield signal
          elsif not ma5_sold and price[:open] >= ma5[idx] and price[:close] < ma5[idx]
            ma5_sold = true
            signal = {:side => 'S', :date => price[:date], :price => ma5[idx].round(2)}
            yield signal
          end

        rescue
          next
        end
      end
    end
  end

end
