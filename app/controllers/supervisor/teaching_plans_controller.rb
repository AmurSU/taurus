class Supervisor::TeachingPlansController < Supervisor::BaseController

  include GosinspParser

  def new
  end

  def fill
    if params[:plan] and params[:plan].class == Tempfile
      @speciality, @results, @errors = parse_and_fill_teaching_plan(params[:plan].read)
    end
  end

end
