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
1. `cp config/nginx.conf.default /etc/nginx/nginx.conf` and edit nginx.conf
1. `sudo service nginx start` start nginx
1. `cp config/youxin.god.default config/youxin.god` and edit nginx.conf
1. 'rvmsudo god -c config/youxin.god' run system monitor
