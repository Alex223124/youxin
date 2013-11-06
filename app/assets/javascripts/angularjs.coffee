#= require angular
#= require angular-resource
#= require angular-ui/ui-router.min
#= require_self
#= require loading-bar.min
#= require_tree ./angularjs

@app = angular.module('youxin', ['ngResource', 'ui.router', 'chieffancypants.loadingBar'])
@app.config(["$httpProvider", (provider) ->
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
])

@app.config ['$httpProvider', ($httpProvider) ->

  interceptor = ['$rootScope', '$q', ($rootScope, $q) ->
    success = (response) ->
      response

    error = (response) ->
      if response.status is 401
        App.alert('登录超时，请重新登录，页面即将跳转', 'error')
        window.location.reload()
      $q.reject(response);

    (promise) ->
      promise.then(success, error)
  ]
  $httpProvider.responseInterceptors.push(interceptor)
]
