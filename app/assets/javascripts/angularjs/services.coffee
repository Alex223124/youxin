@app.factory 'Receipt', ['railsResourceFactory', (railsResourceFactory) ->
  resource = railsResourceFactory {
    url: '/receipts'
    name: 'receipt'
  }
]
