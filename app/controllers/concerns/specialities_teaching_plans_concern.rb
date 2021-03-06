# -*- encoding : utf-8 -*-
module SpecialitiesTeachingPlansConcern
  extend ActiveSupport::Concern

  include GosinspParser

  included do
    if defined? active_scaffold_config and active_scaffold_config
      active_scaffold_config.action_links.add :teaching_plan, :label => "Учебный план", :type => :member, :page => true
      active_scaffold_config.action_links.add :teaching_plan_import, :label => "Импорт учебного плана", :type => :collection, :page => true
      active_scaffold_config.action_links.add :generate_training_assignments, type: :collection, method: :post, page: true
    end
  end

  def teaching_plan
    @speciality = Speciality.find(params[:id])
    tp_years = @speciality.teaching_plans.group(:forming_year).pluck(:forming_year)
    sg_years = @speciality.groups.group(:forming_year).pluck(:forming_year)
    @years = (tp_years | sg_years).sort
    @year = params[:forming_year].present? && params[:forming_year].to_i.in?(@years) ? params[:forming_year].to_i : @years.max
    @teaching_plans = @speciality.teaching_plans.where(forming_year: @year)
    @courses = @teaching_plans.uniq.reorder(:course).pluck(:course)
    @display_courses = params[:course].present? ? [params[:course].to_i] : @courses
    @teaching_plans = @teaching_plans.where(course: params[:course]) if params[:course].present?
    discipline_ids = @teaching_plans.map{|tp| tp.discipline_id}.uniq
    @disciplines = Discipline.reorder(:name).includes(:department).find(discipline_ids)
    render "application/specialities/teaching_plans/show"
  end

  def teaching_plan_import
    if params[:plan] and params[:plan].class == ActionDispatch::Http::UploadedFile
      @specialities = can?(:manage, :all) ? nil : Speciality.accessible_by(current_ability, :update)
      params[:plan].rewind # In case if someone have already read our file
      @speciality, @results, @errors = parse_and_fill_teaching_plan(params[:plan].read, params[:forming_year], @specialities)
      render "application/specialities/teaching_plans/fill"
      return
    end
    render "application/specialities/teaching_plans/new"
  end

  protected

  def create_training_assignments
    created = 0
    speciality_ids = params[:id].present?? params[:id] : marked_records.to_a
    courses = params[:course].present?? [params[:course].to_i] : Group.where(speciality_id: speciality_ids).map(&:course).uniq.sort
    teaching_plans = TeachingPlan.where(speciality_id: speciality_ids, semester: current_semester.number)    
    TrainingAssignment.transaction do
      courses.each do |course|
        forming_year = current_semester.year - course + 1
        course_teaching_plans = teaching_plans.where(course: course, forming_year: forming_year)
        discipline_ids = course_teaching_plans.uniq.pluck(:discipline_id)
        disciplines = Discipline.reorder(:name).includes(:department).find(discipline_ids)
        groups = Group.where(speciality_id: speciality_ids, forming_year: forming_year)
        disciplines.each do |discipline|
          # Lections
          entries = course_teaching_plans.where(discipline_id: discipline.id).where("teaching_plans.lections IS NOT NULL")
          entries.group_by{|entry| entry.lections }.each do |hours, plan_entries|
            group_ids = plan_entries.map(&:group_ids).flatten.uniq
            conditions = {weeks_quantity: 18, hours: hours, lesson_type_id: 1, semester_id: current_semester.id, groups: {id: group_ids}, disciplines: {id: [discipline.id]}}    
            lec = TrainingAssignment.where(conditions).first_or_initialize
            unless lec.persisted?
              lec.group_ids = group_ids
              lec.disciplines = [discipline]
              lec.save and (created += 1)
            end
          end
          # Practics and laboratory works
          [[:practics, 2], [:lab_works, 3]].each do |type, type_id|
            entries = course_teaching_plans.where(discipline_id: discipline.id).where("teaching_plans.#{type} IS NOT NULL")
            entries.group_by{|entry| entry.send(type) }.each do |hours, plan_entries|
              group_ids = plan_entries.map(&:group_ids).flatten.uniq
              group_ids.each do |group_id|
                conditions = {weeks_quantity: 18, hours: hours, lesson_type_id: type_id, semester_id: current_semester.id, groups: {id: group_id}, disciplines: {id: [discipline.id]}}    
                lec = TrainingAssignment.where(conditions).first_or_initialize
                unless lec.persisted?
                  lec.group_ids = [group_id]
                  lec.disciplines = [discipline]
                  lec.save and (created += 1)
                end
              end
            end
          end
        end
      end
      each_marked_record {|r| r.as_marked = false} if marked_records.any?
    end
    created
  end

end