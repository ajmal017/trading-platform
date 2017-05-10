module Strategy

  class MaAdx
    def initialize(historical_data, options={})
      @historical_data = historical_data
      @fast = options[:fast] || 5
      @slow = options[:slow] || 10
      @ma_type = options[:ma_type] || :ema
    end

    def run
      ma_fast = Indicator.create(@ma_type, @fast).run(@historical_data)
      ma_slow = Indicator.create(@ma_type, @slow).run(@historical_data)

      adx = Indicator.create(:adx).run(@historical_data)
      plus_di = Indicator.create(:plusdi).run(@historical_data)
      minus_di = Indicator.create(:minusdi).run(@historical_data)

      @historical_data.each_with_index do |input, idx|
        next if idx == 0 || ma_fast[idx - 1].nil? || ma_slow[idx - 1].nil? ||
          adx[idx].nil? || plus_di[idx - 1].nil? || minus_di[idx - 1].nil?

        if adx[idx] >= 20
          if ma_fast[idx - 1] < ma_slow[idx - 1] && ma_fast[idx] >= ma_slow[idx]
            s = {:side => 'B', :date => input[:date], :price => input[:close]}
            yield s
          elsif ma_fast[idx - 1] > ma_slow[idx - 1] && ma_fast[idx] <= ma_slow[idx]
            s = {:side => 'S', :date => input[:date], :price => input[:close]}
            yield s
          end
        end
      end
      yield nil
    end
  end

end
