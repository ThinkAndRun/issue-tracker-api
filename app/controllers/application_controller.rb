class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user
  around_action :handle_exceptions, if: proc { request.path.include?('/api') }

  def handle_exceptions
    begin
      yield
    rescue ActiveRecord::RecordNotFound => e
      @status = 404
      @message = 'Record not found'
    rescue ArgumentError => e
      @status = 400
    rescue StandardError => e
      @status = 500
    end
    render json: { success: false, message: @message ||
                   e.class.to_s, errors: [{ detail: e.message }] },
                 status: @status unless e.class == NilClass
  end

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
