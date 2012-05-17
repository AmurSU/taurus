require 'test_helper'

class Supervisor::SemestersControllerTest < ActionController::TestCase
  setup do
    @supervisor_semester = supervisor_semesters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:supervisor_semesters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create supervisor_semester" do
    assert_difference('Supervisor::Semester.count') do
      post :create, :supervisor_semester => @supervisor_semester.attributes
    end

    assert_redirected_to supervisor_semester_path(assigns(:supervisor_semester))
  end

  test "should show supervisor_semester" do
    get :show, :id => @supervisor_semester
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @supervisor_semester
    assert_response :success
  end

  test "should update supervisor_semester" do
    put :update, :id => @supervisor_semester, :supervisor_semester => @supervisor_semester.attributes
    assert_redirected_to supervisor_semester_path(assigns(:supervisor_semester))
  end

  test "should destroy supervisor_semester" do
    assert_difference('Supervisor::Semester.count', -1) do
      delete :destroy, :id => @supervisor_semester
    end

    assert_redirected_to supervisor_semesters_path
  end
end
