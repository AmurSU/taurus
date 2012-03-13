class DeptHead::SpecialitiesController < DeptHead::BaseController
  include GosinspParser

  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:code, :name]
    config.nested.add_link('Группы', [:groups])
    config.action_links.add :teaching_plan, :label => "Учебный план", :type => :member, :page => true
    config.action_links.add :teaching_plan_import, :label => "Импорт учебного плана", :type => :collection, :page => true
    config.action_links.add :add_charge_cards, :label => "Автосоздание карт нагрузки", :type => :member, :page => true
  end

  def teaching_plan
    @speciality = Speciality.find(params[:id])
    @teaching_plans = TeachingPlan.find_all_by_speciality_id(@speciality.id)
    discipline_ids = @teaching_plans.map{|tp| tp.discipline_id}.uniq
    @disciplines = Discipline.find(discipline_ids, :order => :name)
    @courses = @teaching_plans.map{|tp| tp.course}.uniq.sort
    render "application/specialities/teaching_plans/show"
  end

  def teaching_plan_import
    if params[:plan] and params[:plan].class == Tempfile
      @specialities = current_dept_head.department.specialities
      @speciality, @results, @errors = parse_and_fill_teaching_plan(params[:plan].read, @specialities)
      render "supervisor/teaching_plans/fill"
      return
    end
  end

  def add_charge_cards
    @speciality = Speciality.find(params[:id])
    discipline_ids = current_dept_head.department.disciplines.all(:select => "id").map{|d| d.id}
    to_remove_ids = @speciality.groups.map{|g| g.jets}.flatten.map{|j| j.charge_card_id}.uniq
    @cards_to_remove = ChargeCard.count(:conditions => {:id => to_remove_ids, :discipline_id => discipline_ids})
  end

  def create_charge_cards
    @speciality = Speciality.find(params[:id])
    discipline_ids = current_dept_head.department.disciplines.all(:select => "id").map{|d| d.id}
    conditions = {:speciality_id => @speciality.id, :discipline_id => discipline_ids}
    if params[:remove]
      ids = @speciality.groups.map{|g| g.jets}.flatten.map{|j| j.charge_card_id}.uniq
      deleted = (ChargeCard.destroy_all(:id => ids, :discipline_id => discipline_ids)).count
    end
    created = 0
    @courses = TeachingPlan.all(:conditions => {:speciality_id => @speciality.id}, :select => "DISTINCT(course)").map{|p| p.course}.sort
    @courses.each do |course|
      groups = @speciality.groups.select{|g| g.course == course}
      if groups.any?
        conditions.merge!({:course => course, :semester => TAURUS_CONFIG["semester"]["current"]["number"]})
        plans = TeachingPlan.all(:conditions => conditions)
        plans.each do |plan|
          created += (plan.create_charge_cards_for(groups)).count
        end
      end
    end
    redirect_to "/dept_head/specialities", :notice => "Создано карт нагрузок: #{created}#{", удалено: #{deleted}" if deleted}"
  end

  protected

  def before_create_save(record)
    if dept = current_dept_head.department
      record.department_id = dept.id
    end
  end

  def conditions_for_collection
    if dept = current_dept_head.department
      discipline_ids = current_dept_head.department.disciplines.all(:select => "id").map{|d| d.id}
      conditions = {:discipline_id => discipline_ids, :semester => TAURUS_CONFIG["semester"]["current"]["number"]}
      ids = TeachingPlan.all(:conditions => conditions, :select => "DISTINCT(speciality_id)").map{ |tp| tp.speciality_id }
      ["department_id = :department_id OR id IN (:id)", {:department_id => dept.id, :id => ids }]
    else
      {:department_id => nil}
    end
  end

  def custom_finder_options
    {:order => "department_id = #{current_dept_head.department_id} DESC, code ASC"}
  end

  def current_user
    return current_dept_head
  end

end
