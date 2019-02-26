shared_examples 'Deny unauthenticated access' do
  header 'Accept', 'application/vnd.issue_tracker_api.v1+json'
  header 'Content-Type', 'application/json'

  example_request 'Deny unauthenticated access' do
    header 'Authorization', 'bad_auth_token'
    do_request
    expect(status).to eq 401
    resp = JSON.parse(response_body)
    expect(resp['error'].to_s).to match(/Not Authorized/)
    example.metadata[:document] = false
  end
end

shared_examples 'Issue not found or action forbidden' do |action|
  header 'Accept', 'application/vnd.issue_tracker_api.v1+json'
  header 'Content-Type', 'application/json'

  let!(:issue) { create(:issue) }
  let!(:unauthorized_user) { create(:user) }

  example_request "Deny #{action} action for unauthorized users" do
    header 'Authorization', JsonWebToken.encode(user_id: unauthorized_user.id)
    do_request
    expect(status).to eq 403
    resp = JSON.parse(response_body)
    expect(resp['error'].to_s).to match(/Forbidden/)
    example.metadata[:document] = false
  end

  example_request 'Show code 404 when record not found' do
    header 'Authorization', JsonWebToken.encode(user_id: issue.user.id)
    do_request(id: -1)
    expect(status).to eq 404
    resp = JSON.parse(response_body)
    expect(resp['error'].to_s).to match(/Not found/)
    example.metadata[:document] = false
  end
end