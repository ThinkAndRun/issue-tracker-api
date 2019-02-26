class Issue < ApplicationRecord
  STATUSES = %w[pending in_progress resolved]
  ASSIGNEE_REQUIRED = %w[in_progress resolved]

  belongs_to :user
  belongs_to :manager,
             class_name: 'User',
             foreign_key: :manager_id,
             optional: true

  validates :status, inclusion: { in: STATUSES }
  validates :status, :title, presence: true
  validate  :assignee_required

  default_scope -> { order(id: :desc) }
  scope :status, -> (status) { where status: status if status.present? }

  private

  def assignee_required
    if manager_id.blank? && (manager_id_changed? || status_changed?) &&
        ASSIGNEE_REQUIRED.include?(status)
      errors.add(:manager_id, "must be assigned when status is '#{status}'")
      return false
    end
  end
end
