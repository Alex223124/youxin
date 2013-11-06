@app.factory 'City', ['$resource', ($resource)->
  base_url = '/china_city'
  $resource "#{base_url}/:id.json", { id: '@id' }, {
    get:
      method: 'GET'
    getProvinces:
      method: 'GET'
      params:
        id: '000000'
  }
]

@app.factory 'DetailOptions', ['$resource', ($resource)->
  base_url = '/account/detail_options'
  $resource "#{base_url}.json", {
    get:
      method: 'GET'
  }
]
