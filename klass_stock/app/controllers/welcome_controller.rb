class WelcomeController < ApplicationController
  def index
    if request.post?
      if params[:username] == 'asdf' and params[:password] == 'jkl;'
        session[:authenticated] = true
        redirect_to '/launchpad'
      else
        redirect_to '/'
      end
    end
  end

  def logout
    session[:authenticated] = nil
    redirect_to '/'
  end
end
