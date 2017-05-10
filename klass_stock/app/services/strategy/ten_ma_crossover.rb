module Strategy

  class TenMaCrossover
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
      ma6 = Indicator.create(@ma_type, 35).run(@historical_data)
      ma7 = Indicator.create(@ma_type, 40).run(@historical_data)
      ma8 = Indicator.create(@ma_type, 45).run(@historical_data)
      ma9 = Indicator.create(@ma_type, 50).run(@historical_data)
      ma10 = Indicator.create(@ma_type, 55).run(@historical_data)
      ma11 = Indicator.create(@ma_type, 60).run(@historical_data)

      ma1_sold = true
      ma2_sold = true
      ma3_sold = true
      ma4_sold = true
      ma5_sold = true
      ma6_sold = true
      ma7_sold = true
      ma8_sold = true
      ma9_sold = true
      ma10_sold = true
      ma11_sold = true

      @historical_data.each_with_index do |input, idx|
        signal = {:date => input[:date], :price => input[:close]}
        begin

          # MA5 crossed MA10
          if ma1_sold && ma0[idx - 1] < ma1[idx - 1] && ma0[idx] >= ma1[idx]
            ma1_sold = false
          elsif !ma1_sold && ma0[idx - 1] > ma1[idx - 1] && ma0[idx] <= ma1[idx]
            ma1_sold = true
          end

          # MA5 crossed MA20
          if !ma1_sold && ma2_sold && ma0[idx - 1] < ma2[idx - 1] && ma0[idx] >= ma2[idx]
            ma2_sold = false
            signal.update(:side => 'B', :fraction_number => 1)
            yield signal
          elsif ma1_sold && !ma2_sold && ma0[idx - 1] > ma2[idx - 1] && ma0[idx] <= ma2[idx]
            ma2_sold = true
            signal.update(:side => 'S', :fraction_number => 1)
            yield signal
          end

          # MA5 crossed MA45
          if !ma2_sold && ma3_sold && ma0[idx - 1] < ma3[idx - 1] && ma0[idx] >= ma3[idx]
            ma3_sold = false
            signal.update(:side => 'B', :fraction_number => 2)
            yield signal
          elsif ma2_sold && !ma3_sold && ma0[idx - 1] > ma3[idx - 1] && ma0[idx] <= ma3[idx]
            ma3_sold = true
            signal.update(:side => 'S', :fraction_number => 2)
            yield signal
          end

          # MA5 crossed MA70
          if !ma3_sold && ma4_sold && ma0[idx - 1] < ma4[idx - 1] && ma0[idx] >= ma4[idx]
            ma4_sold = false
            signal.update(:side => 'B', :fraction_number => 3)
            yield signal
          elsif ma3_sold && !ma4_sold && ma0[idx - 1] > ma4[idx - 1] && ma0[idx] <= ma4[idx]
            ma4_sold = true
            signal.update(:side => 'S', :fraction_number => 3)
            yield signal
          end

          # MA5 crossed MA95
          if !ma4_sold && ma5_sold && ma0[idx - 1] < ma5[idx - 1] && ma0[idx] >= ma5[idx]
            ma5_sold = false
            signal.update(:side => 'B', :fraction_number => 4)
            yield signal
          elsif ma4_sold && !ma5_sold && ma0[idx - 1] > ma5[idx - 1] && ma0[idx] <= ma5[idx]
            ma5_sold = true
            signal.update(:side => 'S', :fraction_number => 4)
            yield signal
          end

          # MA5 crossed MA120
          if !ma5_sold && ma6_sold && ma0[idx - 1] < ma6[idx - 1] && ma0[idx] >= ma6[idx]
            ma6_sold = false
            signal.update(:side => 'B', :fraction_number => 5)
            yield signal
          elsif ma5_sold && !ma6_sold && ma0[idx - 1] > ma6[idx - 1] && ma0[idx] <= ma6[idx]
            ma6_sold = true
            signal.update(:side => 'S', :fraction_number => 5)
            yield signal
          end

          # MA5 crossed MA145
          if !ma6_sold && ma7_sold && ma0[idx - 1] < ma7[idx - 1] && ma0[idx] >= ma7[idx]
            ma7_sold = false
            signal.update(:side => 'B', :fraction_number => 6)
            yield signal
          elsif ma6_sold && !ma7_sold && ma0[idx - 1] > ma7[idx - 1] && ma0[idx] <= ma7[idx]
            ma7_sold = true
            signal.update(:side => 'S', :fraction_number => 6)
            yield signal
          end

          # MA5 crossed MA170
          if !ma7_sold && ma8_sold && ma0[idx - 1] < ma8[idx - 1] && ma0[idx] >= ma8[idx]
            ma8_sold = false
            signal.update(:side => 'B', :fraction_number => 7)
            yield signal
          elsif ma7_sold && !ma8_sold && ma0[idx - 1] > ma8[idx - 1] && ma0[idx] <= ma8[idx]
            ma8_sold = true
            signal.update(:side => 'S', :fraction_number => 7)
            yield signal
          end

          # MA5 crossed MA195
          if !ma8_sold && ma9_sold && ma0[idx - 1] < ma9[idx - 1] && ma0[idx] >= ma9[idx]
            ma9_sold = false
            signal.update(:side => 'B', :fraction_number => 8)
            yield signal
          elsif ma8_sold && !ma9_sold && ma0[idx - 1] > ma9[idx - 1] && ma0[idx] <= ma9[idx]
            ma9_sold = true
            signal.update(:side => 'S', :fraction_number => 8)
            yield signal
          end

          # MA5 crossed MA220
          if !ma9_sold && ma10_sold && ma0[idx - 1] < ma10[idx - 1] && ma0[idx] >= ma10[idx]
            ma10_sold = false
            signal.update(:side => 'B', :fraction_number => 9)
            yield signal
          elsif ma9_sold && !ma10_sold && ma0[idx - 1] > ma10[idx - 1] && ma0[idx] <= ma10[idx]
            ma10_sold = true
            signal.update(:side => 'S', :fraction_number => 9)
            yield signal
          end

          # MA5 crossed MA245
          if !ma10_sold && ma11_sold && ma0[idx - 1] < ma11[idx - 1] && ma0[idx] >= ma11[idx]
            ma11_sold = false
            signal.update(:side => 'B', :fraction_number => 10)
            yield signal
          elsif ma10_sold && !ma11_sold && ma0[idx - 1] > ma11[idx - 1] && ma0[idx] <= ma11[idx]
            ma11_sold = true
            signal.update(:side => 'S', :fraction_number => 10)
            yield signal
          end

        rescue
          next
        end
      end
    end

  end

end
