class StaticController < ApplicationController

  def root
    dir = 'public'
    default_file = dir + '/index_default.html'
    file = dir + '/index.html'
    unless File.exist?(file)
      file = default_file
    end
    render :file => file
  end

  def asset
    final_path = '/assets/' + timestamp + '/' + path
    logger.debug(final_path)
    render :file => final_path
  end

end
