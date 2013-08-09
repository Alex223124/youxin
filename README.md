## 优信(Youxin)
youxin source code

------

### Requirements

* Ruby 2.0.0
* Redis 2.6.11
* MongoDB 2.4.2


### Stacks

* [genghisapp](https://github.com/bobthecow/genghis.git) MongoDB admin app

### Testing
`bundle exec guard` to run autotest

### Install

1. `git clone` clone to local
1. `cd youxin` cd into directory
1. `bundle install`
1. `cp config/mongoid.yml config/mongoid.yml.default` and edit mongoid.yml
1. `cp config/youxin.yml.default config/youxin.yml` and edit youxin.yml
1. `cp config/nginx.conf /etc/nginx/nginx.conf` and edit nginx.conf
1. `cd push_server/faye` and `thin start -C thin.yml` start faye
1. run redis
1. `rake pinyinat:init` if you have create some users before
1. `PIDFILE=./tmp/pids/resque-scheduler.pid BACKGROUND=yes rake resque:scheduler RAILS_ENV=production`
1. `PIDFILE=./tmp/pids/resque-work.pid BACKGROUND=yes rake resque:work RAILS_ENV=production` run schedule jobs
1. `bundle exec unicorn -D -d -E production -c config/unicorn.rb` run rails server
1. `sudo service nginx start` start nginx
