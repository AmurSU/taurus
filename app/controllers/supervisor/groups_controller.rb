class Supervisor::GroupsController < Supervisor::BaseController
  record_select :search_on => :name, :order_by => :name
  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:name, :forming_year, :course, :speciality, :population]
    config.create.columns.exclude :course
    config.update.columns.exclude :course
    config.columns[:speciality].form_ui = :select
    config.action_links.add :teaching_plan, :label => "Учебный план", :type => :member, :page => true
  end

  def teaching_plan
    @group = Group.find(params[:id])
    @charge_cards = @group.charge_cards
    @lesson_types = LessonType.all(:order => :id)
    @teaching_plans = TeachingPlan.find_all_by_speciality_id_and_course_and_semester(
      @group.speciality_id, @group.course, TAURUS_CONFIG["semester"]["current"]["number"]
    )
    discipline_ids = (@charge_cards.map{|cc| cc.discipline_id} + @teaching_plans.map{|tp| tp.discipline_id}).uniq
    @disciplines = Discipline.find(discipline_ids, :order => :name)
    render "application/groups/teaching_plans/show"
  end

protected

  def current_user
    return nil
  end

end
