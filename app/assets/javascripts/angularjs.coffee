#= require unstable/angular
#= require angularjs/rails/resource
#= require_self
#= require_tree ./angularjs

@app = angular.module('youxin', ['rails', 'ngUpload'])
@app.config(["$httpProvider", (provider) ->
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
])
