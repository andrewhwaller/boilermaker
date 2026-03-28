class HomeController < ApplicationController
  def index
    redirect_to conversations_path
  end

  def components
    render Views::Home::Components.new
  end
end
