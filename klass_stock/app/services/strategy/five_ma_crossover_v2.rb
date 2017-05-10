module Strategy

  class FiveMaCrossoverV2
    def initialize(historical_data, ma_type=:sma)
      @historical_data = historical_data
      @ma_type = ma_type
    end

    def run
      ma0 = Indicator.create(@ma_type, 5).run(@historical_data)
      ma1 = Indicator.create(@ma_type, 10).run(@historical_data)
      ma2 = Indicator.create(@ma_type, 15).run(@historical_data)
      ma3 = Indicator.create(@ma_type, 20).run(@historical_data)
      ma4 = Indicator.create(@ma_type, 25).run(@historical_data)
      ma5 = Indicator.create(@ma_type, 30).run(@historical_data)

      ma1_sold = true
      ma2_sold = true
      ma3_sold = true
      ma4_sold = true
      ma5_sold = true

      @historical_data.each_with_index do |price, idx|
        b = {:side => 'B', :date => price[:date], :price => price[:close]}
        s = {:side => 'S', :date => price[:date], :price => price[:close]}

        begin
          if ma1_sold and ma0[idx] > ma1[idx]
            ma1_sold = false
            signal = b
            yield signal
          elsif not ma1_sold and ma0[idx] < ma1[idx]
            ma1_sold = true
            signal = s
            yield signal
          end

          if ma2_sold and ma0[idx] > ma2[idx]
            ma2_sold = false
            signal = b
            yield signal
          elsif not ma2_sold and ma0[idx] < ma2[idx]
            ma2_sold = true
            signal = s
            yield signal
          end

          if ma3_sold and ma0[idx] > ma3[idx]
            ma3_sold = false
            signal = b
            yield signal
          elsif not ma3_sold and ma0[idx] < ma3[idx]
            ma3_sold = true
            signal = s
            yield signal
          end

          if ma4_sold and ma0[idx] > ma4[idx]
            ma4_sold = false
            signal = b
            yield signal
          elsif not ma4_sold and ma0[idx] < ma4[idx]
            ma4_sold = true
            signal = s
            yield signal
          end

          if ma5_sold and ma0[idx] > ma5[idx]
            ma5_sold = false
            signal = b
            yield signal
          elsif not ma5_sold and ma0[idx] < ma5[idx]
            ma5_sold = true
            signal = s
            yield signal
          end
        rescue
          next
        end

      end
    end

  end

end
