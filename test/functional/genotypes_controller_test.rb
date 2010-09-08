require 'test_helper'

class GenotypesControllerTest < ActionController::TestCase
  setup do
    @genotype = genotypes(:one)
  end

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
      post :create, :genotype => @genotype.attributes
    end

    assert_redirected_to genotype_path(assigns(:genotype))
  end

  test "should show genotype" do
    get :show, :id => @genotype.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @genotype.to_param
    assert_response :success
  end

  test "should update genotype" do
    put :update, :id => @genotype.to_param, :genotype => @genotype.attributes
    assert_redirected_to genotype_path(assigns(:genotype))
  end

  test "should destroy genotype" do
    assert_difference('Genotype.count', -1) do
      delete :destroy, :id => @genotype.to_param
    end

    assert_redirected_to genotypes_path
  end
end
