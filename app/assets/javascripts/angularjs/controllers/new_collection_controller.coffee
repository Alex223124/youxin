@newCollectionController =  ["$scope", "receiptService",($scope, receiptService)->
  $scope.submit = (receipt)->
    form = receipt.post.forms.first()
    entities = {}
    for input in form.inputs
      switch input.type
        when "Field::TextField", "Field::TextArea", "Field::NumberField"
          entities[input.identifier] = input.default_value
        when "Field::RadioButton"
          for option in input.options
            if option.value is input.default_value
              entities[input.identifier] = option.id
              break
        when "Field::CheckBox"
          entities[input.identifier] = []
          for option in input.options
            if option.default_selected is true
              entities[input.identifier].push option.id
    receiptService.submitForms form.id, { entities: entities }, (data)->
      form.collectioned = true
      receipt.forms_filled = true
      $scope.read_receipt(receipt)
    .error (data) ->
      App.alert('提交失败，请检查填写内容', 'error')

  $scope.read_receipt = (receipt) ->
    if !receipt.read and receipt.forms_filled
      $http.put("/receipts/#{receipt.id}/read.json").success (data) ->
        receipt.read = true
]
