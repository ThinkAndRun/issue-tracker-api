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

    example 'User will not be created with wrong data', document: :private do
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

    example 'Will not be performed without authorization', document: :private do
      header 'Authorization', 'bad_auth_token'
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
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

    example 'Profile will not be updated with wrong data', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      do_request(email: 'wrong_email_format')
      expect(status).to eq 400
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/is invalid/)
    end

    example 'Profile will not be updated with bad auth_token', document: :private do
      header 'Authorization', 'bad_auth_token'
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
  end
end
