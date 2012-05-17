class Editor::Groups::ChargeCardsController < Editor::BaseController
  def index
    charge_card_search = params[:charge_card].to_s.split
    charge_card = ChargeCard.joins(:jets).where(
      :jets => {:group_id => params[:group_id]},
      :semester_id => current_semester.id
    ).select("charge_cards.id,charge_cards.editor_name")
    charge_card_search.each do |s|
      charge_card = charge_card.select { |c| c.editor_name_include? s }
    end
    charge_card.sort! {|a,b| a.editor_name <=> b.editor_name}
    respond_to do |format|
      format.json { render :json => charge_card.to_json(:only => [:id], :methods => [:editor_name])}
    end
  end
end
