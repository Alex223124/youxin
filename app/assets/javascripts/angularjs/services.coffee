@app.factory 'Receipt', ($resource) ->
  $resource 'receipts/:id.json', {}, {
    query: { method: 'GET', params: { id: 'index' }, isArray: true }
  }