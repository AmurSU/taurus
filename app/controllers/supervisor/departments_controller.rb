class Supervisor::DepartmentsController < Supervisor::BaseController
  active_scaffold do |config|
    config.actions << :delete
    config.columns = [:name, :short_name, :gosinsp_code]
    config.nested.add_link('Специальности', [:specialities])
  end
end
