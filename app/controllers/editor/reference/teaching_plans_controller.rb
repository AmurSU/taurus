class Editor::Reference::TeachingPlansController < Editor::BaseController

  def index
    @groups = Group.all(:order => :name)
  end
  
  def show
    @group = Group.find(params[:group_id])
    @charge_cards = @group.charge_cards
    @lesson_types = LessonType.all(:order => :id)
    @teaching_plans = TeachingPlan.find_all_by_speciality_id_and_course_and_semester(
      @group.speciality_id, @group.course, TAURUS_CONFIG["semester"]["current"]["number"]
    )
    discipline_ids = (@charge_cards.map{|cc| cc.discipline_id} + @teaching_plans.map{|tp| tp.discipline_id}).uniq
    @disciplines = Discipline.find(discipline_ids, :order => :name)
    render "application/groups/teaching_plans/show"
  end

end
