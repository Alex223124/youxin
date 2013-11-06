@app.factory 'Account', ['$resource', ($resource)->
  base_url = '/account'
  $resource "#{base_url}.json", {}, {
    get:
      method: 'GET'
    update:
      method: 'PUT'
  }
]
