# -*- encoding : utf-8 -*-
class Faculty::SpecialitiesController < Faculty::BaseController

  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:code, :name, :department]
    config.nested.add_link :groups
    config.columns[:department].form_ui = :select
    config.actions.add :mark
    config.action_links.add :generate_training_assignments, type: :collection, method: :post, page: true
  end

  include SpecialitiesTeachingPlansConcern

  def generate_training_assignments
    speciality_ids = params[:id].present?? params[:id] : marked_records.to_a
    courses = params[:course].present?? [params[:course].to_i] : Group.where(speciality_id: speciality_ids).map(&:course).uniq.sort
    teaching_plans = TeachingPlan.where(speciality_id: speciality_ids, semester: current_semester.number)
    discipline_ids = teaching_plans.uniq.pluck(:discipline_id)
    disciplines = Discipline.reorder(:name).includes(:department).find(discipline_ids)
    TrainingAssignment.transaction do
      created = 0
      courses.each do |course|
        groups = Group.where(speciality_id: speciality_ids).select{|g| g.course_in(current_semester) == course}
        teaching_plans.where(course: course).each do |plan|
          if plan.lections
            conditions = {weeks_quantity: 18, hours: plan.lections, lesson_type_id: 1, semester_id: current_semester.id, groups: {id: groups.map(&:id)}, disciplines: {id: [plan.discipline_id]}}
            lec = TrainingAssignment.where(conditions).first_or_initialize
            unless lec.persisted?
              lec.groups = groups
              lec.disciplines = [plan.discipline]
              lec.save and (created += 1)
            end
          end
          [[:practics, 2], [:lab_works, 3]].each do |type, type_id|
            groups.each do |group|
              conditions = {weeks_quantity: 18, hours: plan.send(type), lesson_type_id: type_id, semester_id: current_semester.id, groups: {id: [group.id]}, disciplines: {id: [plan.discipline_id]}}
              tassign = TrainingAssignment.where(conditions).first_or_initialize
              unless tassign.persisted?
                tassign.groups = [group]
                tassign.disciplines = [plan.discipline]
                tassign.save and (created += 1)
              end
            end
          end
        end
      end
      each_marked_record {|r| r.as_marked = false} if marked_records.any?
      redirect_to faculty_training_assignments_path(current_faculty), :notice => "Создано записей: #{created}"
    end
  end

  def beginning_of_chain
    super.where(department_id: current_faculty.department_ids)
  end

end
