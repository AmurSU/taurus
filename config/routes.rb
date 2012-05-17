Taurus::Application.routes.draw do

##### Отображение расписания #####

  root :to => redirect('/timetable/groups')

  namespace :timetable do
    resources :groups
    resources :lecturers
    root :to => redirect('/timetable/groups')
  end

##### Общее #####

post 'semesters/change' => 'application#set_current_semester'

##### Редакторский раздел #####

  namespace :editor do
    root :to => redirect('/editor/groups')

    # Редактор по аудиториям
    namespace :classrooms do
      resources :classrooms
      resources :pairs
      resources :charge_cards
      resources :classrooms_sheets
      root :to => 'classrooms#index'
    end

    # Редактор по группам
    namespace :groups do
      resources :groups
      resources :pairs
      resources :classrooms
      resources :charge_cards
      root :to => 'groups#index'
    end

    # Справочные материалы
    namespace :reference do
      resources :groups
      resource :groups_list do
        resources :groups
      end
      resources :departments do as_routes end
      resources :disciplines do as_routes end
      resources :teaching_places do as_routes end
      resources :charge_cards do as_routes end
      get 'teaching_plans' => 'teaching_plans#index'
      get 'teaching_plans/:group_id' => 'teaching_plans#show'
      root :to => redirect('/editor/reference/classroom_sheets')
    end
  end

##### Раздел заведующего кафедрой #####

  namespace :dept_head do
    resources :teaching_places do
      as_routes
      record_select_routes
    end
    resources :disciplines do
      as_routes
      record_select_routes
    end
    resources :groups do
      as_routes
      collection do get :browse end
      member do
        post :select
        get  :teaching_plan
      end
    end
    resources :lecturers do
      as_routes
      record_select_routes
    end
    resources :charge_cards do
      as_routes
    end
    resources :specialities do
      as_routes
      collection do
        get :teaching_plan_import
        post :teaching_plan_import
      end
      member do
        get :add_charge_cards
        get :teaching_plan
        post :create_charge_cards
      end
    end
    root :to => redirect('/dept_head/teaching_places')
  end

##### Раздел супервайзера #####

  namespace :supervisor do
    resources :faculties do as_routes end
    resources :specialities do
      as_routes
      member do get :teaching_plan end
    end
    resources :groups do
      as_routes
      member do get :teaching_plan end
    end
    resources :classrooms do as_routes end
    resources :lecturers do as_routes end
    resources :departments do as_routes end
    resources :semesters do as_routes end
    get 'teaching_plans' => 'teaching_plans#new'
    post 'teaching_plans/fill' => 'teaching_plans#fill'
    root :to => redirect('/supervisor/lecturers')
  end

##### Администраторский раздел #####

  namespace :admin do
    resources :dept_heads do as_routes end
    resources :editors do as_routes end
    resources :supervisors do as_routes end
    resources :admins do as_routes end
    root :to => redirect('/admin/dept_heads')
  end

##### Аутентификация #####

  devise_for :admin, :skip => [:sessions]
  devise_scope :admin do
    get    'admin/login' => 'devise/sessions#new',      :as => :new_admin_session
    post   'admin/login' => 'devise/sessions#create',    :as => :admin_session
    delete 'admin/logout' => 'devise/sessions#destroy', :as => :destroy_admin_session
  end
  devise_for :editor, :skip => [:sessions]
  devise_scope :editor do
    get    'editor/login' => 'devise/sessions#new',      :as => :new_editor_session
    post   'editor/login' => 'devise/sessions#create',    :as => :editor_session
    delete 'editor/logout' => 'devise/sessions#destroy', :as => :destroy_editor_session
  end
  devise_for :dept_head, :skip => [:sessions]
  devise_scope :dept_head do
    get    'dept_head/login' => 'devise/sessions#new',      :as => :new_dept_head_session
    post   'dept_head/login' => 'devise/sessions#create',    :as => :dept_head_session
    delete 'dept_head/logout' => 'devise/sessions#destroy', :as => :destroy_dept_head_session
  end
  devise_for :supervisor, :skip => [:sessions]
  devise_scope :supervisor do
    get    'supervisor/login' => 'devise/sessions#new',      :as => :new_supervisor_session
    post   'supervisor/login' => 'devise/sessions#create',    :as => :supervisor_session
    delete 'supervisor/logout' => 'devise/sessions#destroy', :as => :destroy_supervisor_session
  end

  match '/:controller(/:action(/:id))'

end
