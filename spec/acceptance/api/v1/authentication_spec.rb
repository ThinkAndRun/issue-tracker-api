require 'acceptance_helper'

resource 'Users' do
  header 'Accept', 'application/vnd.issue_tracker_api.v1+json'
  header 'Content-Type', 'application/json'

  post '/api/auth', document: :v1 do
    with_options required: true do
      parameter :email, "User's email"
      parameter :password, "User's password"
    end

    let(:email) { 'regular@example.com' }
    let(:password) { 'password' }
    let!(:user) { create(:user, email: email, password: password) }
    let(:raw_post) { params.to_json }

    example 'Authenticate a user' do
      explanation 'This method authenticates a user and returns an `auth_token`.' \
      'You can authorize your API calls with it.'
      do_request
      expect(status).to be 200
      resp = JSON.parse(response_body)
      expect(resp['auth_token']).to be_present
    end

    example 'Authentication throws an error with invalid credentials', document: false do
      do_request(password: 'wrong_password')
      expect(status).to be 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/invalid credentials/)
    end
  end
end
