class UserSerializer < BasicUserSerializer
  attributes :email, :phone, :bio, :gender, :qq, :blog, :uid

  # Detailable
  attributes :political_status, :ethnic, :birthday, :id_number,
    :parental_tel, :boc_number, :social_security_number, :type_of_household,
    :residential_address, :grade, :zip, :enrollment_region, :poor

  has_one :namespace, serializer: NamespaceSerializer

end