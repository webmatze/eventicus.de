class MetroController < ApplicationController

  before_filter :login_required, :except => [:index, :list, :show]
  layout 'eventicus'

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @metro_pages, @metros = paginate :metros, :per_page => 10
  end

  def show
    @metro = Metro.find(params[:id])
  end

  def new
    @metro = Metro.new
  end

  def create
    @metro = Metro.new(params[:metro])
    if @metro.save
      flash[:notice] = 'Metro was successfully created'.t
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def ajax_create
    @metro = Metro.new(params[:metro])
    if @metro.save
      render :partial => 'event/selectedmetro'
    else
      text = "";
      for error in @metro.errors.full_messages do
        text += "<li>" + error + "</li>"
      end
      render :text => text, :status => 444
    end
  end
  
  def edit
    @metro = Metro.find(params[:id])
  end

  def update
    @metro = Metro.find(params[:id])
    if @metro.update_attributes(params[:metro])
      flash[:notice] = 'Metro was successfully updated'.t
      redirect_to :action => 'show', :id => @metro
    else
      render :action => 'edit'
    end
  end

  def destroy
    Metro.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
