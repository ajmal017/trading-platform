class PreOrdersController < ApplicationController
  def index
    @pre_orders = PreOrder.active
    if request.get?
      if params[:id]
        @pre_order = PreOrder.find(params[:id])
      else
        @pre_order = PreOrder.new
      end
    elsif request.post?
      @pre_order = PreOrder.new(pre_order_params)
      if @pre_order.save
        redirect_to pre_orders_path
      else
        render active: 'index'
      end
    elsif request.patch?
      @pre_order = PreOrder.find(params[:pre_order][:id])
      if @pre_order.update_attributes(pre_order_params)
        redirect_to pre_orders_path
      else
        render active: 'index'
      end
    elsif request.delete?
      @pre_order = PreOrder.find(params[:id])
      @pre_order.destroy
      redirect_to pre_orders_path
    end
  end

  private

  def pre_order_params
    params.require(:pre_order).permit(:symbol, :side, :volume, :price)
  end
end
