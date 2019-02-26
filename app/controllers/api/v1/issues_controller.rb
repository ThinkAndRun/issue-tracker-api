class Api::V1::IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :update, :destroy]
  before_action :check_unpermitted_parameters, only: [:create, :update]

  # GET /api/issues
  def index
    @issues = current_user.issues.status(params[:filter].try(:[], :status))
                          .paginate(page: params[:page], per_page: 25)
    render json: @issues, status: :ok
  end

  # POST /api/issues
  def create
    @issue = current_user.issues.create!(issue_params)
    render json: @issue, status: :created
  rescue ActiveRecord::RecordInvalid => invalid
    render json: { error: invalid.record.errors }, status: :bad_request
  end

  # GET /api/issues/:id
  def show
    render json: @issue, status: :ok
  end

  # PUT /api/issues/:id
  def update
    @issue.update!(issue_params)
    render json: @issue, status: :ok
  rescue ActiveRecord::RecordInvalid => invalid
    render json: { error: invalid.record.errors }, status: :bad_request
  end

  # DELETE /api/issues/:id
  def destroy
    @issue.destroy
    head :no_content
  end

  private

  def issue_params
    params.permit(:title, :description)
  end

  def set_issue
    @issue = current_user.issues.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    if Issue.where(id: params[:id]).exists?
      render json: { error: 'Forbidden' }, status: :forbidden
    else
      render json: { error: 'Not found' }, status: :not_found
    end
  end

  def check_unpermitted_parameters
    render json: { error: 'Forbidden' }, status: :forbidden if
      params[:status] || params[:manager_id]
  end
end
