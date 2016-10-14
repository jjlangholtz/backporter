class GitHubApi
  def initialize(pull_request)
    @client = Octokit::Client.new(
      :access_token  => ENV.fetch('GH_TOKEN') { raise 'set GH_TOKEN env var' },
      :auto_paginate => true
    )
    @pull_request = pull_request
  end

  def labels
    client.labels_for_issue(pull_request.repo, pull_request.id)
  end

  def remove_label(name)
    client.remove_label(pull_request.repo, pull_request.id, name)
  end

  def add_label(name)
    client.add_labels_to_an_issue(pull_request.repo, pull_request.id, [name])
  end

  def comment(content)
    client.add_comment(pull_request.repo, pull_request.id, content)
  end

  def create_issue(title, body)
    client.create_issue(pull_request.repo, title, body, :assignee => pull_request.user)
  end

  private

  attr_reader :client, :pull_request
end
