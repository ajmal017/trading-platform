class PortfoliosController < ApplicationController
  before_filter :get_portfolio, only: [:show, :edit, :update, :deals, :destroy, :enable, :disable]

  def index
    @portfolios = Portfolio.where(user_id: 1).order(:created_at).page(params[:page])
  end

  def new
    @portfolio = Portfolio.new
  end

  def create
    @portfolio = Portfolio.new(portfolio_params)
    @portfolio.user_id = 1
    if @portfolio.save
      redirect_to portfolio_path(@portfolio)
    else
      render action: :new
    end
  end

  def show
    p_net_buy = 0
    p_net_profit = 0
    p_gross_loss = 0
    p_deals = 0
    p_win = 0
    p_loss = 0

    yearly_deals = []
    @deals = @portfolio.deals
    @deals.group_by { |b| b.bought_at.year }.sort { |a, b| a[0] <=> b[0] }.each do |deals|
      net_buy = 0
      deals[1].each do |deal|
        net_buy += DealHandler.calculate_net_buy(deal.bought_price, deal.volume)
      end
      yearly_deals << {year: deals[0], net_buy: net_buy}
    end

    @performances = []
    @deals.group_by { |b| b.sold_at.year }.sort { |a, b| a[0] <=> b[0] }.each do |deals|
      net_profit = 0
      gross_loss = 0
      win = 0
      loss = 0
      deals[1].each do |deal|
        net_profit += deal.realized_pl
        gross_loss += deal.realized_pl if deal.realized_pl < 0
        win += 1 if deal.realized_pl > 0
        loss += 1 if deal.realized_pl < 0
      end

      year = deals[0]
      yd = yearly_deals.find { |y| y[:year] == year }
      net_buy = yd[:net_buy] rescue 0

      pfm = OpenStruct.new
      pfm.year = year
      pfm.net_buy = net_buy
      pfm.net_profit = net_profit
      pfm.percent_profit = net_buy == 0 ? 0 : (net_profit / net_buy * 100)
      pfm.gross_loss = gross_loss
      pfm.percent_loss = net_buy == 0 ? 0 : (gross_loss / net_buy * 100)
      pfm.deals_count = deals[1].size
      pfm.win = win
      pfm.loss = loss
      @performances << pfm

      p_net_buy += net_buy
      p_net_profit += net_profit
      p_gross_loss += gross_loss
      p_deals += deals[1].size
      p_win += win
      p_loss += loss
    end

    percent_profit = p_net_buy == 0 ? 0 : (p_net_profit / p_net_buy * 100)
    percent_loss = p_net_buy == 0 ? 0 : (p_gross_loss / p_net_buy * 100)
    @_portfolio = OpenStruct.new(
      net_buy: p_net_buy,
      net_profit: p_net_profit,
      percent_profit: percent_profit,
      gross_loss: p_gross_loss,
      percent_loss: percent_loss,
      deals_count: p_deals,
      win: p_win,
      loss: p_loss
    )
    @deals = DealDecorator.decorate_collection(@deals.order('created_at desc').limit(10))
    @securities = InHandSecurity.available.where(portfolio_id: @portfolio.id).order(:symbol)
    @securities = InHandSecurityDecorator.decorate_collection(@securities)
  end

  def edit
  end

  def update
    if @portfolio.update_attributes(portfolio_params)
      redirect_to portfolio_path(@portfolio)
    else
      render action: :edit
    end
  end

  def deals
    @deals = Deal.where(portfolio_id: @portfolio.id).order('created_at desc')
                 .page(params[:page]).per(20)
    @deals = @deals.where(symbol: params[:symbol]) if params[:symbol]
    @pages = @deals
    @deals = DealDecorator.decorate_collection(@deals)
  end

  def enable
    @portfolio.active = true
    @portfolio.save
    redirect_to portfolios_path
  end

  def disable
    @portfolio.active = false
    @portfolio.save
    redirect_to portfolios_path
  end

  def destroy
    @portfolio.destroy
    redirect_to portfolios_path
  end

  private

  def get_portfolio
    @portfolio = Portfolio.find(params[:id]) rescue nil
    redirect_to portfolios_path unless @portfolio
  end

  def portfolio_params
    params.require(:portfolio).permit(:name)
  end
end
