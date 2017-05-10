class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :check_permission

  def check_permission
    return if params[:client] == 'klass_trade_client'
    unless request.path == '/'
      redirect_to '/' unless session[:authenticated]
    end
  end
end
