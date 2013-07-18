class Notification::Organization < Notification::Base
  belongs_to :organization, class_name: 'Organization'

  field :status, type: String

  validates :status, inclusion: %w( in out )
  validates :organization_id, presence: true

  scope :_in, ->{ where(status: 'in') }
  scope :_out, ->{ where(status: 'out') }
end
