class CrawlerController < ApplicationController
  def create
    Company.create(:symbol => params[:symbol], :name => params[:name], :market => params[:market])
    render :json => {:status => 'success', :data => {}}
  end

  def update
    company = Company.where(:symbol => params[:symbol]).first
    company.update_attributes(:name_th => params[:name_th]) if company
    render :json => {:status => 'success', :data => {}}
  end
end
