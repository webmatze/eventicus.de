class AccountController < ApplicationController
  
  before_filter :login_required, :except => [:login, :signup]
  #model   :user
  layout  'eventicus'

  def login
    case request.method
      when :post
        if session['user'] = User.authenticate(params['user_login'], params['user_password'])
          flash['notice']  = "Login successful"
          redirect_back_or_default :controller => "account", :action => "welcome"
        else
          @login    = params['user_login']
          @message = "Please check your username and password";
      end
    end
  end
  
  def signup
    case request.method
      when :post
        @user = User.new(params['user'])
        
        if @user.save      
          session['user'] = User.authenticate(@user.login, params['user']['password'])
          flash['notice']  = "Signup successful"
          redirect_back_or_default :controller => "account", :action => "welcome"          
        end
      when :get
        @user = User.new
    end      
  end  
  
  def delete
    if params['id'] and session['user']
      @user = User.find(params['id'])
      @user.destroy
    end
    redirect_back_or_default :controller => "account", :action => "welcome"
  end  
    
  def logout
    session['user'] = nil
	  flash['notice'] = "Logout successful"
	  redirect_to events_url
  end
    
  def welcome
  end

  in_place_edit_for :user, :firstname
  in_place_edit_for :user, :name
  in_place_edit_for :user, :email
  in_place_edit_for :user, :url
  
  def show
  	@user = User.find_by_login params[:id]
    @events = @user.events.paginate(:page => params[:page], :per_page => 10)
    #@event_pages = Paginator.new self, @events.length, 10, params[:page]
  end
  
end
