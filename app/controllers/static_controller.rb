class StaticController < ApplicationController

  def root
    render :file => 'public/assets/current/index.html'
  end

end
