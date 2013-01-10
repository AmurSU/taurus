# -*- encoding : utf-8 -*-
class Admin::DeptHeadsController < Admin::BaseController
  active_scaffold DeptHead do |config|
    config.columns = [:department, :name, :login, :email, :password, :password_confirmation]
    config.columns[:department].form_ui = :record_select
    config.columns[:department].clear_link
  end
end
