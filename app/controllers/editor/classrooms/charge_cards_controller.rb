class Editor::Classrooms::ChargeCardsController < Editor::BaseController
  def index
    charge_card_search = params[:charge_card].to_s.split
    classroom = Classroom.find(params[:classroom_id])
    if classroom.department_lock and classroom.department
      charge_card = ChargeCard.with_recommended_first_for(classroom.department).where(:semester_id => current_semester.id).each do |c|
        c.set_recommended_dept(classroom.department)
      end
    else
      charge_card = ChargeCard.where(:semester_id => current_semester.id)
    end
    charge_card_search.each do |s|
      charge_card = charge_card.select { |c| c.editor_name_include? s }
    end
    respond_to do |format|
      format.json { render :json => charge_card.to_json(:only => [:id], :methods => [:editor_name_with_recommendation])}
    end
  end
end
