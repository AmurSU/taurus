class Editor::Groups::ClassroomsController < ApplicationController
  def index
    classroom_search = params[:classroom].to_s.split
    group = Group.find(params[:group_id])
    dept = group.department
    classroom = Classroom.recommended_first_for(dept).each do |c|
      c.set_recommended_dept(dept)
    end
    classroom_search.each do |s|
      classroom = classroom.select { |c| c.full_name.include? s }
    end
    respond_to do |format|
      format.json { render :json => classroom.to_json(:only => [:id], :methods => [:name_with_recommendation])}
    end
  end
end
