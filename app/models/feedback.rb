class Feedback
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :category, type: String
  field :body, type: String
  field :contact, type: String
  field :user_id
  field :devise, type: String
  field :version_code, type: Integer
  field :version_name, type: String

  attr_accessor :category, :body, :contact, :devise,
    :version_code, :version_name

  belongs_to :user

end
