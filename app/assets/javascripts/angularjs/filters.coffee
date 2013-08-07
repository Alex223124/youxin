@app.filter('attachment_preview', ->
  (attachment) ->
    _get_file_type = (obj) ->
        file_name = obj.file_name
        _getType = (str)->
          arr_cache = str.split(".")
          extension = arr_cache[arr_cache.length-1].toLowerCase()
          switch extension
            when "ppt","pptx"
              file_type = "ppt"
            when "doc","docx"
              file_type = "doc"
            when "xls","xlsx"
              file_type = "xls"
            when "txt"
              file_type = "txt"
            when "rar"
              file_type = "rar"
            when "zip"
              file_type = "zip"
            else
              file_type = "unknown"
          file_type
        obj.dimension = '72,91'
        "/assets/file-extension/#{_getType(file_name)}.png"
    if attachment.image
      attachment.src
    else
      _get_file_type(attachment)

)

@app.filter('attachment_thumb', ->
  (src) ->
    "#{src}?version=thumb"
)

@app.filter('file_size', ->
  (size) ->
    _B = parseFloat(size) / 8
    _KB = (_B / 1000).toFixed(2)
    _MB = (_KB / 1024).toFixed(2)
    _GB = (_MB / 1024).toFixed(2)
    if _KB > 1024
      if _MB > 1024
        "#{_GB}GB"
      else
        "#{_MB}MB"
    else
      "#{_KB}KB"
)

@app.filter('format_form_json', ->
  (form_json) ->
    type_lists =
      text: 'Field::TextField'
      textarea: 'Field::TextArea'
      radio: 'Field::RadioButton'
      checkbox: 'Field::CheckBox'
      number: 'Field::NumberField'
      option: 'Field::Option'
    form_inputs = []
    for field in form_json.fieldlist
      input =
        _type: type_lists[field._type]
        label: field.label
        help_text: field.help_text
        required: field.required

      switch field._type
        when 'radio'
          input.options = []
          for option in field.options
            _option = {}
            if option.value is field.default_value
              _option.default_selected = true
            else
              _option.default_selected = false
            _option._type = type_lists[option._type]
            _option.value = option.value
            input.options.push _option

        when 'checkbox'
          input.options = []
          for option in field.options
            _option = {}
            _option._type = type_lists[option._type]
            _option.value = option.value
            _option.default_selected = option.selected
            input.options.push _option

        when 'number'
          input.default_value = parseFloat(field.default_value) || 0
        else
          input.default_value = field.default_value        
      
      form_inputs.push input

    data = 
      title: form_json.title
      inputs: form_inputs
)

@app.filter('avatar_version', ->
  (url, version) ->
    return '' unless url
    array = url.split('/')
    array[array.length - 1] = "#{version}_#{array.last()}"
    array.join('/')
)