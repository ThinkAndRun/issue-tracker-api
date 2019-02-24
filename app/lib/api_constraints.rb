class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'] =~ regex
  end

  private

  def format_version
    if @version.instance_of?(Array)
      @version.join(',')
    else
      @version
    end
  end

  def regex
    %r{application/vnd.issue_tracker_api.v[#{format_version}]\+json}
  end
end