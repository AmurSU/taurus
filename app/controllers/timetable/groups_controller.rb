class Timetable::GroupsController < Timetable::BaseController

  def index
    @groups = Group.includes({:speciality => {:department => :faculty}}).order(:name)
    @groups = @groups.by_name(params[:group]) if params[:group]
    respond_to do |format|
      format.html do
        if @groups.count == 1
          redirect_to timetable_group_path(@groups.first)
        end
      end
      format.json do
        render :json => @groups.to_json(:only => [:id, :name], :methods => [:course], :include => {
          :speciality => {:only => [:code, :name], :include => {
            :department => {:only => [], :include => {
              :faculty => {:only => :name}
            }}
          }}
        })
      end
    end    
  end
  
  def show
    @id = params[:id].to_i
    unless @group = Group.for_timetable.find_by_id(@id)
      suffix = @terminal ? '?terminal=true' : ''
      redirect_to :controller => 'timetable/groups' + suffix
    else
      @days = Timetable.days
      @times = Timetable.times
      @weeks = Timetable.weeks
      @pairs = @group.get_pairs
    end
  end
end
