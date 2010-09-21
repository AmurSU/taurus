class DeptHead::DisciplinesController < DeptHead::BaseController
  active_scaffold do |config|
    config.columns = [:short_name, :name]
    config.create.columns = [:name, :short_name]
    config.update.columns = [:name, :short_name]
    config.list.sorting = { :name => :asc }
  end

  protected

  def before_create_save(record)
    if dept = current_dept_head.department
      record.department_id = dept.id
    end
  end

  def conditions_for_collection
    if dept = current_dept_head.department
      {:department_id => dept.id}
    else
      {:department_id => nil}
    end
  end
end
