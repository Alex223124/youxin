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
              file_type = "unkonwn"
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
