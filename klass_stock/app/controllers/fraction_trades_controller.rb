class FractionTradesController < ApplicationController
  def index
    if request.post?
      symbol = params[:symbol] ? params[:symbol].strip.upcase : ''
      return redirect_to fraction_trades_path if symbol.empty?

      fraction_trade = FractionTrade.where(:symbol => symbol).first
      if fraction_trade
        unless fraction_trade.active?
          fraction_trade.active = true
          fraction_trade.save
        end
      else
        ft = FractionTrade.new(:symbol => symbol)
        ft.portfolio_id = 1
        ft.save
      end
      redirect_to fraction_trades_path
    end
    @fraction_trades = FractionTrade.active.order(:symbol)
  end

  def show
    @fraction_trade = FractionTrade.where(:symbol => params[:symbol]).first
    redirect_to fraction_trades_path unless @fraction_trade
    if request.post?
      result = @fraction_trade.update_attributes(
        :symbol => params[:new_symbol],
        :volume => params[:volume],
        :f1 => params[:f1],
        :f2 => params[:f2],
        :f3 => params[:f3],
        :f4 => params[:f4],
        :f5 => params[:f5],
        :f6 => params[:f6],
        :f7 => params[:f7],
        :f8 => params[:f8],
        :f9 => params[:f9],
        :f10 => params[:f10],
        :active => params[:active]
      )
      if result
        flash[:notice] = 'Saved'
        redirect_to fraction_trades_path
      else
        flash[:alert] = "Can't save"
        render :show
      end
    end
  end
end
