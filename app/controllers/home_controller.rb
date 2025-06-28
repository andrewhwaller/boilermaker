class HomeController < ApplicationController
  def index
    render Views::Home::Index.new(notice: flash[:notice])
  end
end
