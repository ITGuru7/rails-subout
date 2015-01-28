class Consumers::BaseController < ApplicationController
  before_filter :authenticate_consumer!
  layout 'consumer'
end
