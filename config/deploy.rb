require 'bundler/capistrano'
require 'rvm/capistrano'

## Deployment config for production
set :application, "Agricola Score"
set :deploy_to, "/home/kevin/agricolascore.com"
set :user, "kevin"
set :use_sudo, false
set :keep_releases, 5

## Configure source control
set :scm, "git"
set :repository,  "git://github.com/kmcphillips/agricolascore.com.git"
set :branch, "master"
set :deploy_via, :checkout
set :git_shallow_clone, 1

## Fix for requiring terminal on prod server
default_run_options[:pty] = true

## Role for production
role :web, "198.211.110.159"
role :app, "198.211.110.159"

## Tasks for deploying to Apache Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

## install gems through bundler
namespace :bundle do
  task :install do
    run "cd #{current_path} && bundle install"
  end
end

after "deploy:update", "deploy:cleanup"
