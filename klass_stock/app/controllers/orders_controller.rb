class OrdersController < ApplicationController
  before_filter :get_order, :only => [:show, :edit, :update, :destroy]

  def index
    @orders = Order.where(:portfolio_id => params[:portfolio_id])
                   .order('datetime desc', 'created_at desc').page(params[:page])
    @pages = @orders
    @orders = OrderDecorator.decorate_collection(@orders)
  end

  def new
    begin
      @portfolio = Portfolio.find(params[:portfolio_id])
      @order = @portfolio.orders.new(:datetime => Time.now.strftime('%Y-%m-%d %H:%M:%S'))
    rescue
      redirect_to portfolios_path
    end
  end

  def create
    @order = Order.new(order_params)
    @order.portfolio_id = params[:portfolio_id]
    if @order.save
      redirect_to portfolio_orders_path(params[:portfolio_id])
    else
      render :action => :new
    end
  end

  def show
    redirect_to portfolio_orders_path if params[:id].is_numeric?
    @pages = @orders
    @orders = OrderDecorator.decorate_collection(@orders)
    render 'orders/index'
  end

  def edit
  end

  def update
    # if @order.update_attributes(order_params)
    #   redirect_to portfolio_orders_path(params[:portfolio_id])
    # else
    #   render :action => :edit
    # end
  end

  def destroy
    # @order.destroy
    # redirect_to portfolio_orders_path(params[:portfolio_id])
  end

  private

  def get_order
    if params[:id].is_numeric?
      @order = Order.find(params[:id])
    else
      @orders = Order.where(:portfolio_id => params[:portfolio_id], :symbol => params[:id])
                     .order('datetime desc', 'created_at desc').page(params[:page])
    end
  end

  def order_params
    params.require(:order).permit(:side, :symbol, :datetime, :price, :volume)
  end
end
