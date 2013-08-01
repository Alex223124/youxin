class FormSerializer < BasicFormSerializer
  has_many :inputs, serializer: InputSerializer
end