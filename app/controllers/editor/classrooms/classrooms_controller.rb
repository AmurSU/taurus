class Editor::Classrooms::ClassroomsController < Editor::BaseController

  def index
    flash[:error] = nil
    request.xhr? ? nil : cookies[:classrooms] = YAML.dump([0])
    @classroom_id = params[:classroom_id]
    except = params[:except] ? params[:except].split(',').map { |e| e.to_i } : "0"
    classroom = params[:classroom].to_s.gsub('%', '\%').gsub('_', '\_') + '%'
    respond_to do |format|
      format.html
      format.json { render :json => Classroom.all(:conditions => ['id NOT IN (?) AND name LIKE ?', except, classroom],
        :include => [:building]).to_json(:only => [:id, :name], :include => { :building => { :only => :name } } )}
    end
  end

  def show
    @days = Timetable.days
    @times = Timetable.times
    @weeks = Timetable.weeks
    @classroom = Classroom.find_by_id(params[:id], :include => :pairs)
    unless @classroom
      flash[:error] = 'Нет аудитории с таким названием'
    else
      @pairs = @classroom.pairs.sort_by {|pair| pair.active_at}
      grids = YAML.load(cookies[:classrooms])
      grids << @classroom.id
      cookies[:classrooms] = YAML.dump(grids)
      @classrooms = YAML.load(cookies[:classrooms])

      respond_to do |format|
        format.js
      end
    end
  end

  def edit

  end

  def update

  end

  def destroy
    @id = params[:id]
    grids = YAML.load(cookies[:classrooms])
    grids.delete(@id.to_i)
    cookies[:classrooms] = YAML.dump(grids)
    @classrooms = YAML.load(cookies[:classrooms])

    respond_to do |format|
      format.js
    end
  end
end
