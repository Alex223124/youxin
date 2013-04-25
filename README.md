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
2. `cd youxin` cd into directory
3. `bundle install`
4. `cp config/mongoid.yml config/mongoid.yml.default` and edit mongoid.yml
5. `cp config/youxin.yml.default config/youxin.yml` and edit youxin.yml