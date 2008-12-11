require File.dirname(__FILE__) + '/../test_helper'
require 'location_controller'

# Re-raise errors caught by the controller.
class LocationController; def rescue_action(e) raise e end; end

class LocationControllerTest < Test::Unit::TestCase
  fixtures :locations

  def setup
    @controller = LocationController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = locations(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:locations)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:location)
    assert assigns(:location).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:location)
  end

  def test_create
    num_locations = Location.count

    post :create, :location => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_locations + 1, Location.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:location)
    assert assigns(:location).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Location.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Location.find(@first_id)
    }
  end
end
