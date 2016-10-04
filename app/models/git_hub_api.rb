class GitHubApi
  def initialize(repo, pull_request_id)
    @client = Octokit::Client.new(
      :access_token  => ENV.fetch('GH_TOKEN') { raise 'set GH_TOKEN env var' },
      :auto_paginate => true
    )
    @repo = repo
    @number = pull_request_id
  end

  def remove_label(name)
    client.remove_label(repo, number, name)
  end

  def add_label(name)
    client.add_labels_to_an_issue(repo, number, [name])
  end

  def comment(content)
    client.add_comment(repo, number, content)
  end

  private

  attr_reader :client, :repo, :number
end
