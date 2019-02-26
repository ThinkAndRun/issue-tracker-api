require 'rails_helper'

resource 'Manage' do
  header 'Accept', 'application/vnd.issue_tracker_api.v1+json'
  header 'Content-Type', 'application/json'

  put '/api/manage/issues/:id', document: :v1 do
    parameter :manager_id, "Issue's manager"

    let!(:issue) { create(:issue) }
    let(:id) { issue.id }
    let(:manager) { create(:user, :manager) }
    let(:other_manager) { create(:user, :manager) }
    let(:raw_post) { params.to_json }

    example "Assign issue's manager" do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      explanation 'Assign a manager to the issue. Use your `manager ID` or empty string `\'\'` to unassign.'
      do_request(manager_id: manager.id)
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['manager'].to_s).to include(manager.email)
    end

    example "Will unassign issue's manager as a manager", document: false do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      issue.update!(manager_id: manager.id)
      do_request(manager_id: '')
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['manager']).to be_nil
    end

    example "Will not change issue's manager to other manager", document: false do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      issue.update!(manager_id: nil)
      do_request(manager_id: other_manager.id)
      expect(status).to eq 403
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Forbidden/)
    end
  end

  put '/api/manage/issues/:id', document: :v1 do
    parameter :status_, "Issue's status"

    let!(:manager) { create(:user, :manager) }
    let!(:issue) { create(:issue, manager: manager) }
    let(:id) { issue.id }
    let(:unauthorized_manager) { create(:user, :manager) }
    let(:raw_post) { params.to_json }

    example "Assign issue's status" do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      explanation 'Assign a status to the issue. ' \
        'Status could be: `pending`, `in_progress` or `resolved`.'
      do_request(status: 'in_progress')
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['status']).to eq('in_progress')
    end

    example 'Deny status changes from unauthorized manager', document: false do
      header 'Authorization', JsonWebToken.encode(user_id: unauthorized_manager.id)
      do_request(status: 'in_progress')
      expect(status).to eq 403
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Forbidden/)
    end

    example 'Deny status changes if assignee required', document: false do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      issue.update!(manager_id: nil)
      do_request(status: Issue::ASSIGNEE_REQUIRED.first)
      expect(status).to eq 403
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Forbidden/)
    end
  end

  get '/api/manage/issues', document: :v1 do
    parameter :page, 'Page number (25 issues in the response)'
    parameter :filter, "Filter for the issue's list { filter: { status: 'pending' } }"

    per_page = 25
    u_issues_count = 2
    ou_issues_count = 1

    let!(:user) { create(:user) }
    let!(:issues) { create_list(:issue, u_issues_count, user: user) }
    let!(:other_users_issues) { create_list(:issue, ou_issues_count) }
    let!(:manager) { create(:user, :manager) }

    example 'Show all issues' do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      explanation 'Show all issues from all users.'
      do_request
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(3)
    end

    example 'Show issues list with pagination', document: false do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      create_list(:issue, 30)
      do_request(page: 2)
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(u_issues_count +
                                      ou_issues_count +
                                      30 - per_page)
    end

    example 'Show issues list filtered by status', document: false do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      create_list(:issue, 10, status: 'in_progress',
                              manager: create(:user, :manager))

      do_request(filter: { status: 'in_progress' })
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(10)

      do_request(filter: { status: '' })
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(10 + u_issues_count + ou_issues_count)
    end

    include_examples 'Deny unauthenticated access'
  end
end
