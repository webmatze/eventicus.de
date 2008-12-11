require File.dirname(__FILE__) + '/../test_helper'
require 'metro_controller'

# Re-raise errors caught by the controller.
class MetroController; def rescue_action(e) raise e end; end

class MetroControllerTest < Test::Unit::TestCase
  fixtures :metros

  def setup
    @controller = MetroController.new
    request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = metros(:first).id
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

    assert_not_nil assigns(:metros)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:metro)
    assert assigns(:metro).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:metro)
  end

  def test_create
    num_metros = Metro.count

    post :create, :metro => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_metros + 1, Metro.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:metro)
    assert assigns(:metro).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Metro.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Metro.find(@first_id)
    }
  end
end
