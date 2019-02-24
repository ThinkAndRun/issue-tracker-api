require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'

RspecApiDocumentation.configure do |config|
  config.format = :json
  config.curl_host = 'localhost:3000'
  config.curl_headers_to_filter = %w(Host Cookie X-UA-Compatible ETag Cache-Control X-Request-Id X-Runtime)
  config.request_headers_to_include = %w(Accept Content-Type)
  config.response_headers_to_include = %w(Accept Content-Type)

  IssueTrackerApi::API_VERSIONS.each do |version|
    config.define_group(version) do |config|
      config.filter = version
      config.docs_dir = Rails.root.join('doc', 'api', version.to_s)
    end
  end
end