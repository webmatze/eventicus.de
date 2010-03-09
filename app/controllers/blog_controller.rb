class BlogController < ApplicationController

  before_filter :login_required, :except => [:index, :list, :show]
  layout 'eventicus'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update, :add_comment ],
        :redirect_to => { :action => :list }
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    @blogposts = Blog.find(:all, :order => "created_at DESC")
  end

  def show
    @blogpost = Blog.find(params[:id])
  end

  def new
    @blogpost = Blog.new
  end

  def create
    @blogpost = Blog.new(params[:blog])
    @blogpost.user = session['user']
    if @blogpost.save
      flash[:notice] = 'Blogpost was successfully created'
      redirect_to :controller => 'blog', :action => 'show', :id => @blogpost
    else
      render :action => 'new'
    end
  end

  def edit
    @blogpost = Blog.find(params[:id])
  end

  def update
    @blogpost = Blog.find(params[:id])
    if @blogpost.update_attributes(params[:blog])
    	flash[:notice] = 'Blogpost was successfully updated.'
      redirect_to :controller => 'blog', :action => 'show', :id => @blogpost
    else
      render :action => 'edit'  
    end
  end
  
  def add_comment
    blog = Blog.find(params[:id])
    @comment = Comment.new(params[:comment])
    @comment.user_id = session['user'].id
    if blog.add_comment @comment
      render :partial => 'comment'
    end
  end
  
end
