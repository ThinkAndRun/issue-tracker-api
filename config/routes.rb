Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      post  'auth',     to: 'authentication#authenticate'
      post  'signup',   to: 'users#create'
      get   'profile',  to: 'users#show'
      post  'profile',  to: 'users#update'

      resources :issues, only: %i[index create show update destroy]

      get  'manage/issues', to: 'manage#issues', as: 'manage_issues'
      put  'manage/issues/:id', to: 'manage#issue', as: 'manage_issue'
    end
  end

  # Mount documentation for each API version
  IssueTrackerApi::API_VERSIONS.each do |version|
    mount Apitome::Engine => "/api/docs/#{version}",
          as: "apitome-#{version}",
          constraints: ApitomeVersion.new(version)
  end

  # Optionally default to the last API version
  mount Apitome::Engine => '/api/docs',
        as: 'apitome-default',
        constraints: ApitomeVersion.new(IssueTrackerApi::API_LAST_VERSION)
end
