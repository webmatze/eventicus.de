require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Raise errors beyond the default web-based presentation
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase
  self.use_instantiated_fixtures  = true
  
  fixtures :users
  
  def setup

    @controller = AccountController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_auth_bob
    @request.session['return-to'] = "/bogus/location"

    post :login, "user_login" => "bob", "user_password" => "test"
    assert(@response.has_session_object?("user"))

    assert_equal @bob, @response.session["user"]
    
    assert_redirected_to "/bogus/location"
  end
  
  def test_signup
    @request.session['return-to'] = "/bogus/location"

    post :signup, "user" => { "login" => "newbob", "password" => "newpassword", "password_confirmation" => "newpassword", "email" => "newbob@bob.de" }
    assert(@response.has_session_object?("user"), 'Das user Objekt konnte nicht in der Session gefunden werden')
    
    assert_redirected_to "/bogus/location", 'ist nicht zur richtigen Seite redirected worden'
  end

  def test_bad_signup
    @request.session['return-to'] = "/bogus/location"

    post :signup, "user" => { "login" => "newbob", "password" => "newpassword", "password_confirmation" => "wrong", "email" => "newbob@bob.de" }
    assert(assigns("user").errors.invalid?('password'))
    assert_response :success
    
    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "newpassword", "email" => "newbob@bob.de" }
    assert(assigns("user").errors.invalid?("login"))
    assert_response :success
    
    post :signup, "user" => { "login" => "newbob", "password" => "newpassword", "password_confirmation" => "newpassword" }
    assert(assigns("user").errors.invalid?("email"))
    assert_response :success

    post :signup, "user" => { "login" => "yo", "password" => "newpassword", "password_confirmation" => "wrong", "email" => "newbob@bob.de" }
    assert(assigns("user").errors.invalid?("password"))
    assert(assigns("user").errors.invalid?("login"))
    assert_response(:success)
  end

  def test_invalid_login
    post :login, "user_login" => "bob", "user_password" => "not_correct"
     
    assert(!@response.has_session_object?('user'))
    
    assert(@response.has_template_object?("message"))
    assert(@response.has_template_object?("login"))
  end
  
  def test_login_logoff

    post :login, "user_login" => "bob", "user_password" => "test"
    assert(@response.has_session_object?("user"))

    get :logout
    assert(!@response.has_session_object?("user"))

  end
  
end
