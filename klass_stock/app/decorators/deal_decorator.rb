class DealDecorator < Draper::Decorator
  delegate_all

  def bought_price
    h.number_with_precision(source.bought_price.round(2), :precision => 2, :delimiter => ',')
  end

  def sold_price
    h.number_with_precision(source.sold_price.round(2), :precision => 2, :delimiter => ',')
  end

  def percent_pl
    "#{'%.2f' % source.percent_pl.round(2)}%"
  end

  def realized_pl
    h.number_with_precision(source.realized_pl.round(2), :precision => 2, :delimiter => ',')
  end

  def portfolio_cash_balance
    h.number_with_precision(source.portfolio_cash_balance, :precision => 2, :delimiter => ',')
  end

  def volume
    h.number_with_delimiter(source.volume, :delimiter => ',')
  end

  def bought_at
    source.bought_at.strftime('%Y-%m-%d')
  end

  def sold_at
    source.sold_at.strftime('%Y-%m-%d')
  end
end
