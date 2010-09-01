require 'test_helper'

class GenotypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:genotypes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create genotype" do
    assert_difference('Genotype.count') do
      post :create, :genotype => { }
    end

    assert_redirected_to genotype_path(assigns(:genotype))
  end

  test "should show genotype" do
    get :show, :id => genotypes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => genotypes(:one).to_param
    assert_response :success
  end

  test "should update genotype" do
    put :update, :id => genotypes(:one).to_param, :genotype => { }
    assert_redirected_to genotype_path(assigns(:genotype))
  end

  test "should destroy genotype" do
    assert_difference('Genotype.count', -1) do
      delete :destroy, :id => genotypes(:one).to_param
    end

    assert_redirected_to genotypes_path
  end
end
