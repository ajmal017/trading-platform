module Strategy

  class MACD
    def initialize(historical_data, options={})
      @historical_data = historical_data
      @fast = options[:fast]
      @slow = options[:slow]
      @signal = options[:signal]
    end

    def run
      outputs = Indicator.create(:macd, @fast, @slow, @signal).run(@historical_data)
      macd = outputs[:out_macd]
      signal = outputs[:out_macd_signal]

      adx = Indicator.create(:adx).run(@historical_data)
      plus_di = Indicator.create(:plusdi).run(@historical_data)
      minus_di = Indicator.create(:minusdi).run(@historical_data)

      last_buy = 0
      top = 0

      @historical_data.each_with_index do |input, idx|
        next if idx == 0 || macd[idx - 1].nil? || macd[idx - 2].nil? || macd[idx - 3].nil?

        top = input[:close] if input[:close] > top

        # CUT LOSS
        pl = (input[:close] - top) / top * 100
        if last_buy > 0 && pl <= -10
          last_buy = 0
          top = 0

          s = {:side => 'S', :date => input[:date], :price => input[:close]}
          yield s
        elsif last_buy == 0 &&
              macd[idx - 1] < signal[idx - 1] && macd[idx] >= signal[idx] &&
              macd[idx] > macd[idx - 1] && macd[idx - 1] > macd[idx - 2] &&
              # plus_di[idx] >= 15
              # signal[idx] - macd[idx] < signal[idx - 1] - macd[idx - 1] &&
              # signal[idx - 1] - macd[idx - 1] < signal[idx - 2] - macd[idx - 2] &&
              # signal[idx - 2] - macd[idx - 2] < signal[idx - 3] - macd[idx - 3]

          last_buy = input[:close]
          top = input[:close]

          s = {:side => 'B', :date => input[:date], :price => input[:close]}
          yield s
        # elsif macd[idx - 1] > signal[idx - 1] && macd[idx] <= signal[idx] && last_buy > 0
        #   last_buy = 0
        #   s = {:side => 'S', :date => input[:date], :price => input[:close]}
        #   yield s
        end
      end
      yield nil
    end
  end

end
