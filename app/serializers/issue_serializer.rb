class IssueSerializer < ActiveModel::Serializer
  belongs_to :user, if: :information_for_manager?
  belongs_to :manager, class: 'User', if: :manager_assigned?

  attributes :id, :status, :title, :description, :created_at

  def manager_assigned?
    object.manager.present?
  end

  def information_for_manager?
    current_user.manager?
  end
end
