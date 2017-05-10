class OrderDecorator < Draper::Decorator
  delegate_all

  def side
    source.side.upcase
  end

  def status
    source.closed ? 'Closed' : 'Open'
  end

  def datetime
    source.datetime.strftime('%Y-%m-%d %H:%M:%S')
  end

  def price
    h.number_with_precision(source.price, :precision => 2, :delimiter => ',')
  end

  def volume
    h.number_with_delimiter(source.volume, :delimiter => ',')
  end

end
