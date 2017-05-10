module Strategy

  class Spread
    def initialize(historical_data, spread_up=1, spread_down=5, slots=100)
      @historical_data = historical_data
      @spread_up = spread_up
      @spread_down = spread_down
      @slots = slots
    end

    def run
      ref_buy = 0
      ref_sell = 0
      steps = []

      @historical_data.each do |price|
        moving_price = price[:open]

        if price[:open] >= price[:close]

          while moving_price >= price[:close]
            if ref_buy == 0
              ref_buy = price[:open]
              moving_price = (moving_price - PriceSpread.for(moving_price)).round(2)
              next
            end

            buy_point = (ref_buy + (PriceSpread.for(ref_buy) * @spread_up)).round(2)
            sell_point = (ref_sell - (PriceSpread.for(ref_sell) * @spread_down)).round(2)

            if moving_price >= buy_point and moving_price >= 0.5 and steps.size < @slots
              ref_buy = moving_price
              ref_sell = (moving_price - PriceSpread.for(moving_price)).round(2)
              steps.push moving_price
              signal = {:side => 'B', :date => price[:date], :price => moving_price}
              yield signal
            elsif moving_price <= sell_point and steps.size > 0
              ref_buy = (moving_price + (PriceSpread.for(moving_price) * 3)).round(2)
              ref_sell = moving_price
              steps.pop
              signal = {:side => 'S', :date => price[:date], :price => moving_price}
              yield signal
            end
            moving_price = (moving_price - PriceSpread.for(moving_price)).round(2)
          end

          if steps.size == 0
            ref_buy = price[:close]
          elsif steps.size == @slots
            ref_sell = price[:open]
          end

        elsif price[:open] < price[:close]

          while moving_price <= price[:close]
            if ref_buy == 0
              ref_buy = price[:open]
              moving_price = (moving_price + PriceSpread.for(moving_price)).round(2)
              next
            end

            buy_point = (ref_buy + (PriceSpread.for(ref_buy) * @spread_up)).round(2)
            sell_point = (ref_sell - (PriceSpread.for(ref_sell) * @spread_down)).round(2)

            if moving_price >= buy_point and moving_price >= 0.5 and steps.size < @slots
              ref_buy = moving_price
              ref_sell = (moving_price - PriceSpread.for(moving_price)).round(2)
              steps.push moving_price
              signal = {:side => 'B', :date => price[:date], :price => moving_price}
              yield signal
            elsif moving_price <= sell_point and steps.size > 0
              ref_buy = (moving_price + (PriceSpread.for(moving_price) * 3)).round(2)
              ref_sell = moving_price
              steps.pop
              signal = {:side => 'S', :date => price[:date], :price => moving_price}
              yield signal
            end
            moving_price = (moving_price + PriceSpread.for(moving_price)).round(2)
          end

          if steps.size == 0
            ref_buy = price[:open]
          elsif steps.size == @slots
            ref_sell = price[:close]
          end

        end

      end
    end

  end

end
