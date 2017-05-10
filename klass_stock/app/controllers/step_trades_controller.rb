class StepTradesController < ApplicationController
  def index
    if request.post?
      symbol = params[:symbol] ? params[:symbol].strip.upcase : ''
      return redirect_to step_trades_path if symbol.empty?

      step_trade = StepTrade.where(:symbol => symbol).first
      if step_trade
        unless step_trade.active?
          step_trade.active = true
          step_trade.save
        end
      else
        st = StepTrade.new(:symbol => symbol)
        st.portfolio_id = 1
        st.save
      end
      redirect_to step_trades_path
    end
    @step_trades = StepTrade.active.order(:symbol)
  end

  def show
    @step_trade = StepTrade.where(:symbol => params[:symbol]).first
    redirect_to step_trades_path unless @step_trade
    if request.post?
      result = @step_trade.update_attributes(
        :symbol => params[:new_symbol],
        :volume => params[:volume],
        :max_step => params[:max_step],
        :current_step => params[:current_step],
        :ref_buy => params[:ref_buy],
        :ref_sell => params[:ref_sell],
        :active => params[:active]
      )
      if result
        flash[:notice] = 'Saved'
        redirect_to step_trades_path
      else
        flash[:alert] = "Can't save"
        render :show
      end
    end
  end
end
