class Api::V1::ManageController < ApplicationController
  before_action :set_issue, only: :issue
  before_action :check_manager_rights

  # GET /api/manage/issues
  def issues
    @issues = Issue.status(params[:filter].try(:[], :status))
                   .paginate(page: params[:page], per_page: 25)
    render json: @issues, status: :ok
  end

  # PUT /api/manage/issues/:id
  def issue
    @issue.update!(issue_params)
    render json: @issue, status: :ok
  rescue ActiveRecord::RecordInvalid => invalid
    render json: { error: invalid.record.errors }, status: :bad_request
  end

  private

  def issue_params
    params.permit(:manager_id, :status)
  end

  def set_issue
    @issue = Issue.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not found' }, status: :not_found
  end

  def check_manager_rights
    if !current_user.manager? ||
       cannot_update_manager? ||
       cannot_update_status?
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end

  def cannot_update_manager?
    issue_params[:manager_id] &&
      cannot?(:update_manager, @issue, issue_params[:manager_id])
  end

  def cannot_update_status?
    issue_params[:status] && cannot?(:update_status, @issue)
  end
end
