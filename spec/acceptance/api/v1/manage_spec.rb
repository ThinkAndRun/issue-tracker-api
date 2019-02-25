require 'rails_helper'

resource 'Manage' do
  header 'Accept', 'application/vnd.issue_tracker_api.v1+json'
  header 'Content-Type', 'application/json'

  put '/api/manage/issues/:id', document: :v1 do
    parameter :manager, "Issue's manager"

    let!(:issue) { create(:issue) }
    let(:id) { issue.id }
    let(:manager) { create(:user, :manager) }
    let(:wrong_manager) { create(:user, :manager) }
    let(:raw_post) { params.to_json }

    example 'Assign issue manager' do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      explanation 'Assign a manager to the issue. Use your `manager ID` or empty string `\'\'` to unassign.'
      do_request(manager: manager.id)
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['manager'].to_s).to include(manager.email)
    end

    example "Will unassign issue's manager as a manager", document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      issue.update!(manager_id: manager.id)
      do_request(manager: '')
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['manager']).to be_nil
    end

    example "Will not change issue's manager as a wrong manager", document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: wrong_manager.id)
      issue.update!(manager_id: manager.id)
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
  end

  put '/api/manage/issues/:id', document: :v1 do
    parameter :status_, "Issue's status"

    let!(:manager) { create(:user, :manager) }
    let!(:issue) { create(:issue, manager: manager) }
    let(:id) { issue.id }
    let(:wrong_manager) { create(:user, :manager) }
    let(:raw_post) { params.to_json }

    example 'Assign issue status' do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      explanation 'Assign a status to the issue. ' \
        'Status could be: `pending`, `in_progress` or `resolved`.'
      do_request(status: 'in_progress')
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp['status']).to eq('in_progress')
    end

    example "Will not change issue's status as a wrong manager", document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: wrong_manager.id)
      do_request(status: 'in_progress')
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end

    example 'Will not change issue without assigned manager', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: wrong_manager.id)
      issue.update!(manager_id: nil)
      do_request(status: 'in_progress')
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
  end

  get '/api/manage/issues', document: :v1 do
    parameter :page, 'Page number (25 issues in the response)'
    parameter :filter, "Filter for the issue's list { filter: { status: 'pending' } }"

    let!(:user) { create(:user) }
    let!(:issues) { create_list(:issue, 2, user: user) }
    let!(:other_users_issues) { create_list(:issue, 1) }
    let!(:manager) { create(:user, :manager) }

    example 'Show all issues' do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      explanation 'Show all issues from all users.'
      do_request
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(3)
    end

    example 'Show issues list with pagination', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      create_list(:issue, 30)
      do_request(page: 2)
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(2 + 1 + 30 - 25)
    end

    example 'Show issues list filtered by status', document: :private do
      header 'Authorization', JsonWebToken.encode(user_id: manager.id)
      create_list(:issue, 10, status: 'in_progress')

      do_request(filter: { status: 'in_progress' })
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(10)

      do_request(filter: { status: '' })
      expect(status).to eq 200
      resp = JSON.parse(response_body)
      expect(resp.count).to eq(13)
    end

    example 'Will not be performed without authorization', document: :private do
      header 'Authorization', 'bad_auth_token'
      do_request
      expect(status).to eq 401
      resp = JSON.parse(response_body)
      expect(resp['error'].to_s).to match(/Not Authorized/)
    end
  end
end
