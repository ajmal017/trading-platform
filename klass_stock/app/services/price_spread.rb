class PriceSpread
  def self.for(price, etf=false)
    return 0 if price <= 0
    if etf or price < 2
      0.01
    elsif price >= 2 and price < 5
      0.02
    elsif price >= 5 and price < 10
      0.05
    elsif price >= 10 and price < 25
      0.1
    elsif price >= 25 and price < 100
      0.25
    elsif price >= 100 and price < 200
      0.5
    elsif price >= 200 and price < 400
      1.0
    elsif price >= 400
      2.0
    end
  end
end
