class PortfolioDecorator < Draper::Decorator
  delegate_all

  def net_buy
    h.number_with_precision(source.net_buy.round(2), precision: 2, delimiter: ',')
  end

  def net_profit
    h.number_with_precision(source.net_profit.round(2), precision: 2, delimiter: ',')
  end

  def percent_profit
    profit = h.number_with_precision(source.percent_profit.round(2), precision: 2, delimiter: ',')
    "#{profit}%"
  end

  def gross_loss
    h.number_with_precision(source.gross_loss.round(2), precision: 2, delimiter: ',')
  end

  def percent_loss
    loss = h.number_with_precision(source.percent_loss.round(2), precision: 2, delimiter: ',')
    "#{loss}%"
  end

  def deals_count
    h.number_with_delimiter(source.deals_count, delimiter: ',')
  end

  def win
    w = h.number_with_delimiter(source.win, delimiter: ',')
    if source.deals_count == 0
      percent = 0
    else
      percent = source.win / source.deals_count.to_f * 100
    end
    "#{w} (#{'%.2f' % percent}%)"
  end

  def loss
    l = h.number_with_delimiter(source.loss, delimiter: ',')
    if source.deals_count == 0
      percent = 0
    else
      percent = source.loss / source.deals_count.to_f * 100
    end
    "#{l} (#{'%.2f' % percent}%)"
  end
end
