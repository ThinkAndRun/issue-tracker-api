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

  default_scope -> { order(created_at: :desc) }
  scope :status, -> (status) { where status: status if status.present? }

  def update_manager!(new_manager_id, current_user_id)
    return unless User.find(current_user_id).manager?
    return if manager_id.present? && manager_id != current_user_id
    return if manager_id.blank? && new_manager_id != current_user_id
    return if ASSIGNEE_REQUIRED.include? status && new_manager_id.blank?
    update!(manager_id: new_manager_id)
  end

  def update_status!(new_status, current_user_id)
    return unless User.find(current_user_id).manager?
    return if ASSIGNEE_REQUIRED.include? new_status && manager_id.blank?
    return if manager_id != current_user_id
    update!(status: new_status)
  end
end
