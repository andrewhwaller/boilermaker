class HomeController < ApplicationController
  def index
    render Views::Home::Index.new(notice: flash[:notice])
  end

  def components
    render Views::Home::Components.new
  end
end
