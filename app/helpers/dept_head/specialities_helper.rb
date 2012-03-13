module DeptHead::SpecialitiesHelper

  def list_row_class(record)
    'alien-speciality' if record.department_id != current_dept_head.department_id
  end

end
