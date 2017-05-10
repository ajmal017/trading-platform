module Strategy

  class ADX
    def initialize(historical_data, options={})
      @historical_data = historical_data
    end

    def run
      adx = Indicator.create(:adx).run(@historical_data)
      plus_di = Indicator.create(:plusdi).run(@historical_data)
      minus_di = Indicator.create(:minusdi).run(@historical_data)

      bought = 0

      @historical_data.each_with_index do |input, idx|
        begin
          price = input[:close]
          if adx[idx] >= 20
            if bought == 0 && plus_di[idx] > minus_di[idx]
              bought = input[:close]
              s = {:side => 'B', :date => input[:date], :price => price}
              yield s
            elsif bought > 0 && plus_di[idx] < minus_di[idx]
              bought = 0
              s = {:side => 'S', :date => input[:date], :price => price}
              yield s
            end
          end
        rescue
          next
        end
      end

      yield nil
    end
  end

end
