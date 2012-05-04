class Timetable::BaseController < ApplicationController
  layout 'timetable'
  before_filter :check_for_terminal
  
  def check_for_terminal
    @terminal = params.include? :terminal
  end

  # The options parameter is the hash passed in to 'url_for'
  def default_url_options(options={})
    options.merge!(:terminal => @terminal) if @terminal
    options
  end

end
