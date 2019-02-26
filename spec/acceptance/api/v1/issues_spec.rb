require 'rails_helper'

resource 'Issues' do
  header 'Accept', 'application/vnd.issue_tracker_api.v1+json'
  header 'Content-Type', 'application/json'

  get '/api/issues', document: :v1 do
    parameter :page, 'Page number (25 issues in the response)'
    parameter :filter, "Filter for the issue's, example: { filter: { status: 'pending' } }"

    per_page = 25
    u_issues_count = 2
    ou_issues_count = 30

    let!(:user) { create(:user) }
    let!(:issues) { create_list(:issue, u_issues_count,
                                        user: user) }
    let!(:other_user) { create(:user) }
    let!(:other_users_issues) { create_list(:issue, ou_issues_count,
                                                    user: other_user) }
    let!(:manager) { create(:user, :manager) }

    example 'List of issues' do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      explanation "Show user's issues."
      do_request
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(u_issues_count)
    end

    example 'List of issues with pagination (25 issues in the response)', document: false do
      header 'Authorization', JsonWebToken.encode(user_id: other_user.id)
      do_request(page: 2)
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(ou_issues_count - per_page)
    end

    example 'List of issues filtered by status', document: false do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      create_list(:issue, 10, user: user,
                              status: 'in_progress',
                              manager: create(:user, :manager))

      do_request(filter: { status: 'in_progress' })
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(10)

      do_request(filter: { status: '' })
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(10 + u_issues_count)
    end

    include_examples 'Deny unauthenticated access'
  end

  get '/api/issues/:id', document: :v1 do
    let!(:issue) { create(:issue) }
    let!(:id) { issue.id }

    example 'Show an issue' do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      explanation "Show user's issue."
      do_request
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['id']).to eq(issue.id)
    end

    include_examples 'Issue not found or action forbidden', 'show'
    include_examples 'Deny unauthenticated access'
  end

  post '/api/issues', document: :v1 do
    parameter :title, "Issue's title", required: true
    parameter :description, "Issue's description"
    let!(:user) { create(:user) }
    let(:raw_post) { params.to_json }

    example 'Create an issue' do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      explanation 'This method creates an issue for the current user.'
      do_request(title: Faker::Lorem.sentence)
      expect(status).to eq 201
      expect(user.issues.count).to eq 1
    end

    example 'Deny issue creation with wrong data', document: false do
      header 'Authorization', JsonWebToken.encode(user_id: user.id)
      do_request
      expect(status).to eq 400
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/can't be blank/)
    end

    include_examples 'Deny unauthenticated access'
  end

  put '/api/issues/:id', document: :v1 do
    parameter :title, "Issue's title"
    parameter :description, "Issue's description"

    let!(:issue) { create(:issue) }
    let(:id) { issue.id }
    let(:manager) { create(:user, :manager) }
    let(:raw_post) { params.to_json }

    example 'Update an issue' do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      explanation "This method updates user's issue."
      do_request(title: 'new title')
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['title'].to_s).to eq('new title')
    end

    example "Regular user can't update issue's status", document: false do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      do_request(status: 'in_progress')
      expect(status).to eq 403
      resp = JSON.parse(response_body)
      expect(resp['error']).to eq('Forbidden')
    end

    example "Regular user can't update issue's manager", document: false do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      do_request(manager_id: manager.id)
      expect(status).to eq 403
      resp = JSON.parse(response_body)
      expect(resp['error']).to eq('Forbidden')
    end

    include_examples 'Issue not found or action forbidden', 'update'
    include_examples 'Deny unauthenticated access'
  end

  delete '/api/issues/:id', document: :v1 do
    let!(:issue) { create(:issue) }
    let(:id) { issue.id }

    example 'Delete an issue' do
      header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
      explanation "This method deletes user's issue."
      do_request
      expect(status).to eq 204
    end

    include_examples 'Issue not found or action forbidden', 'delete'
    include_examples 'Deny unauthenticated access'
  end
end

