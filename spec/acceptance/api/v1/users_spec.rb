require 'acceptance_helper'

resource 'Users' do
  header 'Accept', 'application/vnd.issue_tracker_api.v1+json'
  header 'Content-Type', 'application/json'

  post '/api/signup', document: :v1 do
    with_options required: true do
      parameter :name, "User's name"
      parameter :email, "User's email"
      parameter :password, "User's password"
    end
    parameter :password_confirmation, 'Confirm the password'
    parameter :manager, 'Assign a manager role to a user'

    let(:name) { 'Regular User' }
    let(:email) { 'regular@example.com' }
    let(:password) { 'password' }
    let(:password_confirmation) { 'password' }
    let(:manager) { false }
    let(:raw_post) { params.to_json }

    example 'Create user' do
      explanation 'This method creates a user and returns an `auth_token`.' \
      'You can authorize your API calls with it.'
      do_request
      expect(status).to eq 201
      resp = JSON.parse(response_body)
      expect(resp['auth_token']).to be_present
    end

    example 'Deny user creation with wrong data', document: false do
      do_request(password_confirmation: 'wrong_password')
      expect(status).to eq 400
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/doesn't match Password/)
    end
  end

  get '/api/profile', document: :v1 do
    let!(:user) { create(:user) }

    example 'Show profile' do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      explanation "Show user's profile information."
      do_request
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['email']).to be_present
    end

    include_examples 'Deny unauthenticated access'
  end

  post '/api/profile', document: :v1 do
    parameter :name, "User's name"
    parameter :email, "User's email"
    parameter :password, "User's password"
    parameter :password_confirmation, 'Confirm the password'
    parameter :manager, 'Assign a manager role to a user'

    let!(:user) { create(:user) }
    let(:name) { 'new name' }
    let(:email) { 'newemail@example.com' }
    let(:password) { 'new_password' }
    let(:password_confirmation) { 'new_password' }
    let(:manager) { false }
    let(:raw_post) { params.to_json }

    example 'Update profile' do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      explanation "This method updates user's profile."
      do_request
      expect(status).to eq 200
    end

    example 'Deny profile update with wrong data', document: false do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      do_request(email: 'wrong_email_format')
      expect(status).to eq 400
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/is invalid/)
    end

    include_examples 'Deny unauthenticated access'
  end
end
