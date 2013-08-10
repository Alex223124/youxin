#= require unstable/angular
#= require_self
#= require_tree ./angularjs

@app = angular.module('youxin', [])
@app.config(["$httpProvider", (provider) ->
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
])

@app.config ['$httpProvider', ($httpProvider) ->
  
  interceptor = ['$rootScope', '$q', ($rootScope, $q) ->
    success = (response) ->
      response

    error = (response) ->
      if response.status is 401
        window.location.reload()
      $q.reject(response);

    (promise) ->
      promise.then(success, error)
  ]
  $httpProvider.responseInterceptors.push(interceptor)
]