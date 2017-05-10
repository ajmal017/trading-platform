module Strategy

  class MaSpread
    def initialize(historical_data, spread_up=1, spread_down=3, slots=100, etf=false)
      @historical_data = historical_data
      @spread_up = spread_up
      @spread_down = spread_down
      @slots = slots
      @etf = etf
    end

    def run
      ref_price = 0
      steps = []

      ma = Indicator.create(:ema, 5).run(@historical_data)

      @historical_data.each_with_index do |price, idx|
        next if ma[idx].nil? or ma[idx - 1].nil?

        moving_price = price[:open]

        if price[:open] >= price[:close]

          while moving_price >= price[:close]
            if ref_price == 0
              ref_price = price[:open]
              moving_price = (moving_price - PriceSpread.for(moving_price, @etf)).round(2)
              next
            end

            buy_point = (ref_price + (PriceSpread.for(ref_price, @etf) * @spread_up)).round(2)
            sell_point = (ref_price - (PriceSpread.for(ref_price, @etf) * @spread_down)).round(2)

            if moving_price >= buy_point and steps.size < @slots and
                ma[idx].round(2) > ma[idx - 1].round(2) and moving_price >= 0.50
              ref_price = moving_price
              steps.push moving_price
              signal = {:side => 'B', :date => price[:date], :price => moving_price}
              yield signal
            elsif moving_price <= sell_point and steps.size > 0
              ref_price = moving_price
              if moving_price <= 0.50
                while true
                  break if steps.size == 0
                  steps.pop
                  signal = {:side => 'S', :date => price[:date], :price => moving_price}
                  yield signal
                end
              else
                steps.pop
                signal = {:side => 'S', :date => price[:date], :price => moving_price}
                yield signal
              end
            end
            moving_price = (moving_price - PriceSpread.for(moving_price, @etf)).round(2)
          end

          if steps.size == 0
            ref_price = price[:close]
          elsif steps.size == @slots
            ref_price = price[:open]
          end

        elsif price[:open] < price[:close]

          while moving_price <= price[:close]
            if ref_price == 0
              ref_price = price[:open]
              moving_price = (moving_price + PriceSpread.for(moving_price, @etf)).round(2)
              next
            end

            buy_point = (ref_price + (PriceSpread.for(ref_price, @etf) * @spread_up)).round(2)
            sell_point = (ref_price - (PriceSpread.for(ref_price, @etf) * @spread_down)).round(2)

            if moving_price >= buy_point and steps.size < @slots and
                ma[idx].round(2) > ma[idx - 1].round(2) and moving_price >= 0.50
              ref_price = moving_price
              steps.push moving_price
              signal = {:side => 'B', :date => price[:date], :price => moving_price}
              yield signal
            elsif moving_price <= sell_point and steps.size > 0
              ref_price = moving_price
              if moving_price <= 0.50
                while true
                  break if steps.size == 0
                  steps.pop
                  signal = {:side => 'S', :date => price[:date], :price => moving_price}
                  yield signal
                end
              else
                steps.pop
                signal = {:side => 'S', :date => price[:date], :price => moving_price}
                yield signal
              end
            end
            moving_price = (moving_price + PriceSpread.for(moving_price, @etf)).round(2)
          end

          if steps.size == 0
            ref_price = price[:open]
          elsif steps.size == @slots
            ref_price = price[:close]
          end

        end

      end
    end

  end

end
