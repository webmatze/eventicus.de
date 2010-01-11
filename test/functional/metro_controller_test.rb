require File.dirname(__FILE__) + '/../test_helper'
require 'metro_controller'

# Re-raise errors caught by the controller.
class MetroController; def rescue_action(e) raise e end; end

class MetroControllerTest < Test::Unit::TestCase
  fixtures :metros, :users

  def setup
    @controller = MetroController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first = metros(:one)
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
    get :show, :id => @first.id

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

  def test_create_loggedin
    @request.session['user'] = users(:bob)
    
    num_metros = Metro.count

    post :create, :metro => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_metros + 1, Metro.count
  end

  def test_edit_loggedin
    @request.session['user'] = users(:bob)
    
    get :edit, :id => @first.id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:metro)
    assert assigns(:metro).valid?
  end

  def test_update_loggedin
    @request.session['user'] = users(:bob)
    post :update, :id => @first.id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first
  end

  def test_destroy_loggedin
    assert_nothing_raised {
      Metro.find(@first.id)
    }

    @request.session['user'] = users(:bob)

    post :destroy, :id => @first.id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Metro.find(@first.id)
    }
  end
end
