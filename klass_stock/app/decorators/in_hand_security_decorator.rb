class InHandSecurityDecorator < Draper::Decorator
  delegate_all

  def sum_price
    h.number_with_precision(source.sum_price.round(2), :precision => 2, :delimiter => ',')
  end

  def sum_volume
    h.number_with_delimiter(source.sum_volume, :delimiter => ',')
  end

  def average_price
    '%.2f' % ((source.sum_price + (source.sum_price * 0.00168846)) / source.sum_volume).round(2)
  end
end
