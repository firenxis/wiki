require 'bundler/capistrano'

set :application, "wiki"
set :repository,  "git://github.com/firenxis/wiki.git"

set :scm, 'git'
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

ssh_options[:keys] = ["default_key.pem"]


set :user, 'ubuntu'
set :branch, "master"
set :git_shallow_clone, 1

set :runner, user

HOSTNAME = "ec2-184-72-72-242.compute-1.amazonaws.com"

set :deploy_to, "/home/#{user}/apps"

role :web, HOSTNAME
role :app, HOSTNAME
role :db,  HOSTNAME, :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

RAILS_CMD = "/home/#{user}/apps/shared/bundle/ruby/1.8/bin/rails"


namespace :deploy do
  task :start do
    run "cd #{current_path} && RAILS_ENV=production #{RAILS_CMD} s -d -p6001"
  end
  
  task :stop do
    pid_file = "#{current_path}/tmp/pids/server.pid"
    run "if [ -e #{pid_file}]; then kill -9 `cat #{pid_file}`; fi"
  end
  
  task :restart do
    stop
    start
  end

  task :apt_get_extras do
     run "#{sudo} apt-get install -y libsqlite3-dev"    
  end

  task :create_subdirs do
    run "mkdir -p /home/#{user}/apps/shared/pids"
    run "mkdir -p /home/#{user}/apps/shared/log"        
  end
  
end
after('deploy:update_code', 'deploy:apt_get_extras')
after('deploy:update_code', 'deploy:create_subdirs')




# namespace :bundler do
#   task :bundle_install do
#     run "#{sudo} apt-get install -y libxslt-dev libxml2-dev"
#     run "cd #{current_path} && #{sudo} bundle install --without development test" 
#   end
# end
# after("deploy:symlink", "bundler:bundle_install")