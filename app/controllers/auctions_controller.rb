class AuctionsController < ApplicationController
  def index
    @auctions = current_company.auctions
  end
end
