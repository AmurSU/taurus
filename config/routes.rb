ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |a|
    a.resources :dept_heads, :active_scaffold => true
    a.resources :editors, :active_scaffold => true
    a.resources :supervisors, :active_scaffold => true
    a.resources :admins, :active_scaffold => true
    a.root :controller => 'dept_heads'
  end

  map.namespace :editor do |e|
    # Pair editor based on classrooms
    e.namespace :classrooms do |c|
      c.resources :classrooms
      c.resources :pairs
      c.resources :charge_cards
      c.resources :classrooms_sheets
      c.root :controller => 'classrooms'
    end
    # Pair editor based on groups
    e.namespace :groups do |g|
      g.resources :groups
      g.resources :pairs
      g.resources :classrooms
      g.resources :charge_cards
      g.root :controller => 'groups'
    end
    # Miscellaneous reference materials for editor needs
    e.namespace :reference do |r|
      r.resources :groups
      r.resource  :groups_list do |list|
        list.resources :groups
      end
      r.resources :departments, :active_scaffold => true
      r.resources :disciplines, :active_scaffold => true
      r.resources :teaching_places, :active_scaffold => true
      r.resources :charge_cards, :active_scaffold => true
      r.connect 'teaching_plans', :controller => "teaching_plans", :action => "index"
      r.connect 'teaching_plans/:group_id', :controller => "teaching_plans", :action => "show"
      r.root :controller => 'classrooms_sheets'
    end
    e.root :controller => 'classrooms/classrooms_sheets'
  end

  map.namespace :dept_head do |d|
    d.resources :teaching_places, :active_scaffold => true, :collection => {:browse => :get}, :member => {:select => :post}
    d.resources :disciplines, :active_scaffold => true, :collection => {:browse => :get}, :member => {:select => :post}
    d.resources :groups, :active_scaffold => true, :collection => {:browse => :get}, :member => {:select => :post, :teaching_plan => :get}
    d.resources :lecturers, :active_scaffold => true, :collection => {:browse => :get}, :member => {:select => :post}
    d.resources :specialities, :active_scaffold => true,
      :member => {:teaching_plan => :get, :create_charge_cards => :post, :add_charge_cards => :get},
      :collection => {:teaching_plan_import => [:get, :post]}
    d.root :controller => 'teaching_places'
  end

  map.namespace :supervisor do |s|
    s.resources :faculties, :active_scaffold => true
    s.resources :specialities, :active_scaffold => true, :member => {:teaching_plan => :get}
    s.resources :groups, :active_scaffold => true, :member => {:teaching_plan => :get}
    s.resources :classrooms, :active_scaffold => true
    s.resources :lecturers, :active_scaffold => true
    s.connect 'teaching_plans', :controller => "teaching_plans", :action => "new", :method => :get
    s.connect 'teaching_plans/fill', :controller => "teaching_plans", :action => "fill", :method => :post
    s.root :controller => 'lecturers'
  end

  map.namespace :timetable do |t|
    t.resources :groups
    t.resources :lecturers
    t.root :controller => 'groups'
  end

  map.resources :classrooms

#  map.admin_root '/admin/departments', :controller => 'admin/dept_heads'
#  map.editor_root '/editor/classrooms', :controller => 'editor/classrooms'
#  map.supervisor_root '/supervisor/lecturers', :controller => 'supervisor/lecturers'
#  map.dept_head_root '/dept_head/lecturers', :controller => 'dept_head/teaching_places'

  map.devise_for :admin, :path_names => { :sign_in => 'login', :sign_out => 'logout'}
  map.new_admin_session '/admin/login', :controller => 'sessions', :action => 'new', :conditions => { :method => :get }
  map.admin_session '/admin/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }
  map.destroy_admin_session '/admin/logout', :controller => 'sessions', :action => 'destroy', :conditions => { :method => :get }

  map.devise_for :editor, :path_names => { :sign_in => 'login', :sign_out => 'logout'}
  map.new_editor_session '/editor/login', :controller => 'sessions', :action => 'new', :conditions => { :method => :get }
  map.editor_session '/editor/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }
  map.destroy_editor_session '/editor/logout', :controller => 'sessions', :action => 'destroy', :conditions => { :method => :get }

  map.devise_for :supervisor, :path_names => { :sign_in => 'login', :sign_out => 'logout'}
  map.new_supervisor_session '/supervisor/login', :controller => 'sessions', :action => 'new', :conditions => { :method => :get }
  map.supervisor_session '/supervisor/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }
  map.destroy_supervisor_session '/supervisor/logout', :controller => 'sessions', :action => 'destroy', :conditions => { :method => :get }

  map.devise_for :dept_head, :path_names => { :sign_in => 'login', :sign_out => 'logout'}
  map.new_dept_head_session '/dept_head/login', :controller => 'sessions', :action => 'new', :conditions => { :method => :get }
  map.dept_head_session '/dept_head/login', :controller => 'sessions', :action => 'create', :conditions => { :method => :post }
  map.destroy_dept_head_session '/dept_head/logout', :controller => 'sessions', :action => 'destroy', :conditions => { :method => :get }

  map.root :controller => "timetable/groups"

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
