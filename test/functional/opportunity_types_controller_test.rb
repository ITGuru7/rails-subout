require 'test_helper'

class OpportunityTypesControllerTest < ActionController::TestCase
  setup do
    @opportunity_type = opportunity_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:opportunity_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create opportunity_type" do
    assert_difference('OpportunityType.count') do
      post :create, opportunity_type: {  }
    end

    assert_redirected_to opportunity_type_path(assigns(:opportunity_type))
  end

  test "should show opportunity_type" do
    get :show, id: @opportunity_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @opportunity_type
    assert_response :success
  end

  test "should update opportunity_type" do
    put :update, id: @opportunity_type, opportunity_type: {  }
    assert_redirected_to opportunity_type_path(assigns(:opportunity_type))
  end

  test "should destroy opportunity_type" do
    assert_difference('OpportunityType.count', -1) do
      delete :destroy, id: @opportunity_type
    end

    assert_redirected_to opportunity_types_path
  end
end
