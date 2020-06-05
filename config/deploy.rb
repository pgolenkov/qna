# config valid for current version and patch releases of Capistrano
lock "~> 3.14.0"

set :application, "qna"
set :deploy_user, "deploy"

set :repo_url, "git@github.com:pashex/qna.git"
set :deploy_to, "/home/deploy/qna"

set :passenger_restart_with_touch, false

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/master.key"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"

set :sidekiq_options_per_process, [
  "--queue default --queue mailers"
]

after 'deploy:publishing', 'unicorn:restart'
