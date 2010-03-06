class AccountController < ApplicationController
  
  before_filter :login_required, :except => [:login, :signup, :show, :link_user_accounts]
  layout  'eventicus'

  def login
    case request.method
      when :post
        if session['user'] = User.authenticate(params['user_login'], params['user_password'])
          flash[:notice]  = t(:login_successful)
          redirect_back_or_default :controller => "account", :action => "welcome"
        else
          @login    = params['user_login']
          @message = t(:check_username_password);
      end
    end
  end
  
  def signup
    case request.method
      when :post
        @user = User.new(params['user'])
        
        if @user.save      
          session['user'] = User.authenticate(@user.login, params['user']['password'])
          flash[:notice]  = t(:signup_successful)
          redirect_back_or_default :controller => "account", :action => "welcome"          
        end
      when :get
        @user = User.new
        @user.time_zone = 'Berlin'
    end      
  end  
  
  def update
    @user = session['user']
    if params['user']['password'].empty? && params['user']['password_confirmation'].empty?
      params['user'].delete 'password'
      params['user'].delete 'password_confirmation'
    end
    @user.attributes = params['user']
    if @user.valid? && @user.save  
      @user.reload
      if params['user']['password'] && @user.password == params['user']['password']
        @user.change_password(@user.password)
      end
      flash[:notice]  = t(:update_successful)
      redirect_to :controller => "account", :action => "show", :id => session['user']  
    else              
      render :action => 'edit'
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
    session[:facebook_session] = nil
	  flash[:notice] = t(:logout_successful)
	  redirect_to events_url
  end
    
  def welcome
  end
  
  # Einen Avatar bearbeiten oder hochladen
  def avatar
    @user = session['user']
    @avatar = @user.avatar
  end
  
  def upload
    @user = session['user']
    @avatar = @user.avatar || Avatar.new(:uploaded_data => params[:avatar_file])
    
    @service = AvatarService.new(@user, @avatar)
    
    if @user.avatar and @service.update_avatar(params[:avatar_file])
      flash[:notice] = t(:avatar_uploaded)
      redirect_to :action => 'avatar'
    elsif @user.avatar.nil? and @service.save
      flash[:notice] = t(:avatar_uploaded)
      redirect_to :action => 'avatar'
    else
      @avatar = @service.avatar
      render :action => 'avatar'
    end
  end
  
  def edit
    @user = session['user']
  end
  
  def show
  	@user = User.find params[:id]
    @events = @user.events.paginate(:conditions => { :scrapingid => nil }, :page => params[:page], :per_page => 10)
    #@event_pages = Paginator.new self, @events.length, 10, params[:page]
  end
  
  def link_user_accounts
    if session['user'].nil?
      #register with fb
      User.create_from_fb_connect(facebook_session.user)
    else
      #connect accounts
      session['user'].link_fb_connect(facebook_session.user.id) unless session['user'].fb_user_id == facebook_session.user.id
    end
    redirect_to '/'
  end
  
end
