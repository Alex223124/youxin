class Organization
  include Mongoid::Document
  include Mongoid::Paranoia # Soft delete
  include Mongoid::Timestamps # Add created_at and updated_at fields

  field :name, type: String
  field :parent_id

  belongs_to :parent, class_name: 'Organization'
  has_many :children, class_name: 'Organization', foreign_key: :parent_id

  validates :name, presence: true
  validates :parent_id, presence: true, allow_nil: true
  validate :parent_exists, if: ->(organization) { organization.parent_id.present? }


  def parent_exists
    if Organization.where(id: self.parent_id).blank?
      self.errors.add :parent_id, "not exist"
    end
  end

end
