class IntradayQuotesController < ApplicationController
  force_ssl

  def create
    unless params[:bid_price].to_f > 0 and params[:offer_price].to_f > 0
      return render json: {}, callback: params[:callback]
    end
    quote = IntradayQuote.new(
              datetime: DateTime.now,
              symbol: params[:symbol],
              bid_price: params[:bid_price].to_f,
              bid_volume: params[:bid_volume].to_i,
              offer_price: params[:offer_price].to_f,
              offer_volume: params[:offer_volume].to_i,
              last_price: params[:last_price].to_f)
    if quote.save
      render json: {status: Time.now}, callback: params[:callback]
    else
      render json: {status: '500 Application Error'}, callback: params[:callback]
    end
  end

end
