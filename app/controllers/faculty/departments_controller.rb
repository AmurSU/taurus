# -*- encoding : utf-8 -*-
class Faculty::DepartmentsController < Faculty::BaseController
  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:name, :short_name, :gosinsp_code, :dept_head]
    config.list.columns = [:name, :short_name, :gosinsp_code, :dept_head]
    config.columns[:dept_head].form_ui = :select
    config.columns[:dept_head].clear_link
    config.nested.add_link :specialities
    config.nested.add_link :teaching_places
    config.nested.add_link :disciplines
  end

  include DepartmentsConcern

end
