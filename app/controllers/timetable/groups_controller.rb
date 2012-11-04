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
      format.xml
      format.json do
        render :json => @groups.to_json(:only => [:name], :methods => [:course], :include => {
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
    begin
      @group = Group.for_timetable.from_param(params[:id])
    rescue ActiveRecord::RecordNotFound
      # Not found? Well, may be this is old bookmarked address? Try find by id.
      @group = Group.for_timetable.find(params[:id])
      redirect_to timetable_group_path(@group), :status => 301, :notice => "Вы зашли на эту страницу по устаревшей ссылке! Обновите закладки в вашем браузере! Правильная ссылка: #{self.class.helpers.link_to(URI.unescape(timetable_group_url(@group)), timetable_group_path(@group))}".html_safe
      expires_in 1.year, :public => true
      return
    end
    @days = Timetable.days
    @times = Timetable.times
    @weeks = Timetable.weeks
    @pairs = @group.get_pairs(current_semester)
    respond_to do |format|
      format.html
      format.xml
      format.xlsx do
        render :xlsx => 'show', :filename => "Расписание занятий группы #{@group.name}.xlsx"
      end
    end
  end
end
