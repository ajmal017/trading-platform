class MonitoredSecuritiesController < ApplicationController

  def index
    @securities = MonitoredSecurity.order('active desc, symbol')

    symbol = params[:symbol]
    symbol = symbol ? symbol.strip.upcase : nil
    return if symbol.nil? or symbol.empty?

    if request.get?
      @security = MonitoredSecurity.where(:symbol => symbol).first
    end

    if request.post?
      security = MonitoredSecurity.where(:symbol => symbol).first
      if security
        if security.active?
          new_symbol = params[:new_symbol] ? params[:new_symbol].strip.upcase : nil
          if new_symbol and not new_symbol.empty? and symbol != new_symbol
            exist = false
            if Stock.where(:symbol => new_symbol).first
              exist = true
            elsif Warrant.where(:symbol => new_symbol).first
              exist = true
            elsif DerivativeWarrant.where(:symbol => new_symbol).first
              exist = true
            elsif ETF.where(:symbol => new_symbol).first
              exist = true
            end
            if exist
              security.update_attributes(:symbol => new_symbol,
                                         :last_trading_date => params[:last_trading_date],
                                         :s1 => params[:s1], :s2 => params[:s2], :s3 => params[:s3])
            end
          else
            security.update_attributes(:last_trading_date => params[:last_trading_date],
                                       :s1 => params[:s1], :s2 => params[:s2], :s3 => params[:s3])
          end
        else
          security.active = true
          security.save
        end
      else
        exist = false
        if Stock.where(:symbol => symbol).first
          exist = true
        elsif Warrant.where(:symbol => symbol).first
          exist = true
        elsif DerivativeWarrant.where(:symbol => symbol).first
          exist = true
        elsif ETF.where(:symbol => symbol).first
          exist = true
        end
        if exist
          MonitoredSecurity.create(:symbol => symbol,
                                   :last_trading_date => params[:last_trading_date],
                                   :s1 => params[:s1], :s2 => params[:s2], :s3 => params[:s3])
        end
      end
      return redirect_to :action => :index
    end

    if request.delete?
      security = MonitoredSecurity.where(:symbol => symbol).first
      security.update_attributes(s1: false, s2: false, s3: false, active: false) if security
      return redirect_to :action => :index
    end
  end

end
