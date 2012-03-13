class Supervisor::SpecialitiesController < Supervisor::BaseController
  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:code, :name, :department]
    config.nested.add_link('Группы', [:groups])
    config.columns[:department].form_ui = :select
    config.action_links.add :teaching_plan, :label => "Учебный план", :type => :member, :page => true
  end

  def teaching_plan
    @speciality = Speciality.find(params[:id])
    @teaching_plans = TeachingPlan.find_all_by_speciality_id(@speciality.id)
    discipline_ids = @teaching_plans.map{|tp| tp.discipline_id}.uniq
    @disciplines = Discipline.find(discipline_ids, :order => :name)
    @courses = @teaching_plans.map{|tp| tp.course}.uniq.sort
    render "application/specialities/teaching_plans/show"
  end

protected

  def current_user
    return nil
  end

end
