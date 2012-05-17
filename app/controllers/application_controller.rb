# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  clear_helpers
  before_filter :set_current_semester

  helper_method :current_semester
  def current_semester
    @current_semester
  end

  helper_method :user_signed_in?
  def user_signed_in?
    admin_signed_in? || supervisor_signed_in? || dept_head_signed_in? || editor_signed_in?
  end

  helper_method :current_user
  def current_user
    current_admin || current_supervisor || current_dept_head || current_editor
  end

  def set_current_semester
    unless params[:semester_id]
      unless session[:current_semester_id]
        year = Date.today.year - (Date.today.month < 8 ? 1 : 0)
        number = Date.today.month < 8 ? 2 : 1
        @current_semester = Semester.find_by_year_and_number_and_full_time(year, number, true)
      else
        @current_semester = Semester.find(session[:current_semester_id])
      end
    else
      @current_semester = Semester.find(params[:semester_id])
    end
    @current_semester = Semester.first unless @current_semester
    Group.current_semester = @current_semester
    session[:current_semester_id] = @current_semester.id if user_signed_in?
    redirect_to (request.referer.blank?? timetable_groups_path : request.referer) if params[:semester_id]
  end

end
