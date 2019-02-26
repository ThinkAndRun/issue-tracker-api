class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.manager?
      can :assign_manager, Issue do |issue, new_manager_id|
        issue.manager_id.blank? && new_manager_id == user.id
      end

      can :unassign_manager, Issue do |issue, new_manager_id|
        issue.manager_id == user.id &&
          new_manager_id.blank? &&
          Issue::ASSIGNEE_REQUIRED.exclude?(issue.status)
      end

      can :update_manager, Issue do |issue, new_manager_id|
        if new_manager_id.present?
          can? :assign_manager, issue, new_manager_id
        else
          can? :unassign_manager, issue, new_manager_id
        end
      end

      can :update_status, Issue do |issue|
        issue.manager_id == user.id
      end
    end
  end
end