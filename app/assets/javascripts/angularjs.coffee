#= require angular
#= require_self
#= require_tree ./angularjs

@app = angular.module('youxin', [])
@app.config(["$httpProvider", (provider) ->
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
])
