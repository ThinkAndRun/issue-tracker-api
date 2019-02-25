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
    @issue.update_manager!(issue_params[:manager],
                           current_user.id) if issue_params[:manager]
    @issue.update_status!(issue_params[:status],
                          current_user.id) if issue_params[:status]
    render json: @issue, status: :ok
  rescue ActiveRecord::RecordInvalid => invalid
    render json: { error: invalid.record.errors }, status: :bad_request
  end

  private

  def issue_params
    params.permit(:manager, :status)
  end

  def set_issue
    @issue = Issue.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not Authorized' }, status: :unauthorized
  end

  def check_manager_rights
    if !current_user.manager? ||
       (@issue&.manager&.present? && @issue&.manager != current_user) ||
       (params[:status] && @issue&.manager != current_user)
      render json: { error: 'Not Authorized' }, status: :unauthorized
    end
  end
end
