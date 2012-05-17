class Editor::Reference::ChargeCardsController < Editor::BaseController
  active_scaffold :charge_card do |config|
    config.actions = [:list, :search, :nested]
    config.list.columns = [:teaching_place, :assistant_teaching_place, :lesson_type, :discipline, :hours_quantity, :hours_per_week, :weeks_quantity, :groups]
    config.columns[:teaching_place].clear_link
    config.columns[:assistant_teaching_place].clear_link
    config.columns[:discipline].clear_link
    config.columns[:groups].clear_link
  end

  def conditions_for_collection
    {:semester_id => current_semester.id}
  end

end
