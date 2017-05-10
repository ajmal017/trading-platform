class ZoneTradesController < ApplicationController
  def index
    if request.post?
      symbol = params[:symbol] ? params[:symbol].strip.upcase : ''
      return redirect_to zone_trades_path if symbol.empty?

      zone_trade = ZoneTrade.where(:symbol => symbol).first
      if zone_trade
        unless zone_trade.active?
          zone_trade.active = true
          zone_trade.save
        end
      else
        st = ZoneTrade.new(:symbol => symbol)
        st.portfolio_id = 1
        st.save
      end
      redirect_to zone_trades_path
    end
    @zone_trades = ZoneTrade.active.order(:symbol)
  end

  def show
    @zone_trade = ZoneTrade.where(:symbol => params[:symbol]).first
    redirect_to zone_trades_path unless @zone_trade
    if request.post?
      result = @zone_trade.update_attributes(
        symbol: params[:new_symbol],
        volume: params[:volume],
        available: params[:available],
        ref_sell: params[:ref_sell],
        active: params[:active]
      )
      if result
        flash[:notice] = 'Saved'
        redirect_to zone_trades_path
      else
        flash[:alert] = "Can't save"
        render :show
      end
    end
  end
end
