# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

#require 'mongrel_cluster/recipes'
require 'bundler/capistrano'
require 'rvm/capistrano'

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "eventicus"
set :repository, "git@github.com:webmatze/eventicus.de.git"

set :rvm_ruby_string, 'ruby-1.8.7-p371@eventicus'
set :rvm_type, :system
set :rvm_path, "/usr/local/rvm"

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "eventicus.de"
role :app, "eventicus.de"
role :db,  "eventicus.de", :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :deploy_to, "/webapps/#{application}" # defaults to "/u/apps/#{application}"
set :user, "deploy"            # defaults to the currently logged in user
set :scm, :git               # defaults to :subversion
set :scm_username, "webmatze"
set :use_sudo, false
#set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25


# =============================================================================
# TASKS
# =============================================================================
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end

desc 'Link shared directories and files'
task :after_update_code, :roles => :app do
  run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{shared_path}/avatars/ #{release_path}/public/avatars"
  run "ln -nfs #{shared_path}/db/production.sqlite3 #{release_path}/db/production.sqlite3"
  run "ln -nfs #{shard_path}/bundled_resources/ #{release_path}/public/bundles"
end
after "deploy:update_code", "after_update_code"

after "deploy", "deploy:migrate"
after 'deploy', 'deploy:cleanup'
