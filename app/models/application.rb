class Application
  include Mongoid::Document
  include Mongoid::Timestamps # Add created_at and updated_at fields
  include Workflow

  field :applicant_id
  field :organization_id
  field :operator_id
  field :state
  workflow_column :state

  validates :applicant_id, presence: true
  validates :organization_id, presence: true

  belongs_to :applicant, class_name: 'User', inverse_of: :applicant
  belongs_to :organization
  belongs_to :operator, class_name: 'User', inverse_of: :operator

  workflow do
    state :waiting do
      event :accept, transitions_to: :accepted
      event :reject, transitions_to: :rejected
    end
    state :accepted
    state :rejected
  end

  private
  def accept
    organization.push_member(applicant)
  end

end
