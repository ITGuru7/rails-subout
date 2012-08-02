require 'test_helper'

class RegionTypesControllerTest < ActionController::TestCase
  setup do
    @region_type = region_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:region_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create region_type" do
    assert_difference('RegionType.count') do
      post :create, region_type: {  }
    end

    assert_redirected_to region_type_path(assigns(:region_type))
  end

  test "should show region_type" do
    get :show, id: @region_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @region_type
    assert_response :success
  end

  test "should update region_type" do
    put :update, id: @region_type, region_type: {  }
    assert_redirected_to region_type_path(assigns(:region_type))
  end

  test "should destroy region_type" do
    assert_difference('RegionType.count', -1) do
      delete :destroy, id: @region_type
    end

    assert_redirected_to region_types_path
  end
end
