class Timetable::LecturersController < Timetable::BaseController

  def index
    @lecturers = Lecturer.order(:name)
    @lecturers = @lecturers.by_name(params[:lecturer].strip) if params[:lecturer] && params[:lecturer].strip.any?
    respond_to do |format|
      format.html do
        if @lecturers.count == 1
          redirect_to timetable_lecturer_path(@lecturers.first)
        end
      end
      format.json do
        render :json => @lecturers.to_json(:only => [:id, :name])
      end
    end
  end

  def show
    @id = params[:id].to_i
    unless @lecturer = Lecturer.find_by_id(@id)
      suffix = @terminal ? '?terminal=true' : ''
      redirect_to :controller => 'timetable/lecturers' + suffix
    else
      teaching_places = @lecturer.teaching_places
      charge_cards = []
      teaching_places.each do |tp|
        charge_cards << tp.charge_cards
        charge_cards << tp.assistant_charge_cards
      end
      charge_cards = charge_cards.flatten
      
      pairs = Array.new
      charge_cards.each do |card|
        pairs << card.pairs(:include => :subgroups)
      end
      pairs = pairs.flatten
      @days = Timetable.days
      @times = Timetable.times
      @weeks = Timetable.weeks
      @pairs = Array.new(@days.size).map!{Array.new(@times.size).map!{Array.new(@weeks.size + 1).map!{Array.new}}}
      pairs.each do |pair|
        @pairs[pair.day_of_the_week - 1][pair.pair_number - 1][pair.week] << pair
      end
    end
  end
end
