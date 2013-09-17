error =
  presence: '此项为必填项'
  numericality: '此项必须为数字'

validate = (form) ->
  fields = form.getElementsByClassName('field')

  submit_btn = form.getElementsByClassName('submit-btn')[0]
  submit_btn.value = '提交中...'
  submit_btn.disabled = true

  # remove form_error
  form_errors = form.getElementsByClassName('form-error')
  for form_error in form_errors
    form_error.parentNode.removeChild(form_error) if !!form_error

  error_flag = false
  for field in fields
    # check wheather it is required
    if field.getElementsByClassName('required')
      input = field.getElementsByClassName('input-wrap')[0]
      label = field.getElementsByTagName('label')[0]

      # remove error_label
      error_labels = label.getElementsByClassName('error')
      for error_label in error_labels
        error_label.parentNode.removeChild(error_label)

      # required
      required = !!label.getElementsByClassName('required')[0]

      klasses = input.getAttribute('class').split(' ')
      for klass in klasses
        if klass is 'number_field' and not validate_numericality_of(input)
          add_error(label, error.numericality)
          error_flag = true
        if required and klass isnt 'input-wrap'
          unless validate_prensence_of(input, klass)
            add_error(label, error.presence)
            error_flag = true

  submit_btn.disabled = false

  if error_flag
    form_error_label = create_element('small', '表单有错，请检查后再次提交')
    form_error_label.className = 'form-error'
    form.insertBefore form_error_label, fields[0]
    submit_btn.value = '提交'

    # Prevent submit action
    event.preventDefault()

    # Jump to anchor
    top = document.getElementsByName('form')[0].offsetTop
    window.scrollTo(0, top)


validate_prensence_of = (input, klass) ->
  switch klass
    when 'text_field', 'number_field'
      !!input.getElementsByTagName('input')[0].value
    when 'text_area'
      !!input.getElementsByTagName('textarea')[0].value
    when 'radio_button', 'check_box'
      options = input.getElementsByTagName('input')
      for option in options
        if option.checked
          return true
      false

validate_numericality_of = (input) ->
  !input.getElementsByTagName('input')[0].value or !!input.getElementsByTagName('input')[0].value.match ///^[+-]?\d+(\.\d+)?$///

add_error = (label, text) ->
  error_label = create_element('small', text)
  error_label.className = 'error'
  label_text = label.getElementsByClassName('label-text')[0]
  label_text.appendChild error_label


create_element = (tag_name, text=null) ->
  element = document.createElement(tag_name)
  if !!text
    text = document.createTextNode(text)
    element.appendChild text
  element

window.validate = validate
