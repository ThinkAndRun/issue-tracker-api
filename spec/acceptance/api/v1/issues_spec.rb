require 'rails_helper'

resource 'Issues' do
  header 'Accept', 'application/vnd.issue_tracker_api.v1+json'
  header 'Content-Type', 'application/json'

  get '/api/issues', document: :v1 do
    parameter :page, 'Page number (25 issues in the response)'
    parameter :filter, "Filter for the issue's list { filter: { status: 'pending' } }"

    let!(:user) { create(:user) }
    let!(:issues) { create_list(:issue, 2, user: user) }
    let!(:other_user) { create(:user) }
    let!(:other_users_issues) { create_list(:issue, 30, user: other_user) }
    let!(:manager) { create(:user, :manager) }

    example 'Show issues list' do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      explanation "Show user's issues list."
      do_request
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(2)
    end

    example 'Show issues list with pagination', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: other_user.id)
      do_request(page: 2)
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(30-25)
    end

    example 'Show issues list filtered by status', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      create_list(:issue, 10, user: user, status: 'in_progress')

      do_request(filter: { status: 'in_progress' })
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(10)

      do_request(filter: { status: '' })
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(12)
    end

    example 'Will not be performed without authorization', document: :private do
      header 'Authorization', 'bad_auth_token'
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
  end

  get '/api/issues/:id', document: :v1 do
    let!(:issue) { create(:issue) }
    let!(:id) { issue.id }

    example 'Show issue' do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      explanation "Show user's issue."
      do_request
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['id']).to eq(issue.id)
    end

    example 'Will not be performed without authorization', document: :private do
      header 'Authorization', 'bad_auth_token'
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
  end

  post '/api/issues', document: :v1 do
    parameter :title, "Issue's title", required: true
    parameter :description, "Issue's description"
    let!(:user) { create(:user) }
    let(:raw_post) { params.to_json }

    example 'Create issue' do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      explanation 'This method creates issue for a current user.'
      do_request(title: Faker::Lorem.sentence)
      expect(status).to eq 201
      expect(user.issues.count).to eq 1
    end

    example 'Issue will not be created with wrong data', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      do_request
      expect(status).to eq 400
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/can't be blank/)
    end

    example 'Issue will not be created with bad auth_token', document: :private do
      header 'Authorization', 'bad_auth_token'
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
  end

  put '/api/issues/:id', document: :v1 do
    parameter :title, "Issue's title"
    parameter :description, "Issue's description"
    let!(:issue) { create(:issue) }
    let(:wrong_user) { create(:user) }
    let(:id) { issue.id }
    let(:manager) { create(:user, :manager) }
    let(:raw_post) { params.to_json }

    example 'Update issue' do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      explanation "This method updates user's issue."
      do_request(title: 'new title')
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['title'].to_s).to eq('new title')
    end

    example 'Issue will not be updated with wrong user', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: wrong_user.id)
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end

    example 'Issue will not be created with bad auth_token', document: :private do
      header 'Authorization', 'bad_auth_token'
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end

    example "Will not update issue's status as a regular user", document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      do_request(status: 'in_progress')
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['status']).to eq('pending')
    end

    example "Will not update issue's manager as a regular user", document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      do_request(manager: true)
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['manager']).to eq(nil)
    end
  end

  delete '/api/issues/:id', document: :v1 do
    let!(:issue) { create(:issue) }
    let(:wrong_user) { create(:user) }
    let(:id) { issue.id }

    example 'Delete issue' do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      explanation "This method deletes user's issue."
      do_request
      expect(status).to eq 204
    end

    example 'Issue will not be deleted with wrong user', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: wrong_user.id)
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end

    example 'Issue will not be deleted with bad auth_token', document: :private do
      header 'Authorization', 'bad_auth_token'
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
  end
end

