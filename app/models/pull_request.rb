class PullRequest
  def initialize(params)
    @data = params.as_json
  end

  def id
    data.dig('pull_request', 'number')
  end

  def repo
    data.dig('repository', 'full_name')
  end

  def merge_commit_sha
    merged? ? data.dig('pull_request', 'merge_commit_sha') : ''
  end

  def merged?
    data['action'] == 'closed' && data.dig('pull_request', 'merged') == true
  end

  def label
    labeled? ? data.dig('pull_request', 'label', 'name') : ''
  end

  def labeled?
    data['action'] == 'labeled'
  end

  def includes_target_label?
    client.labels.any? { |label| label.name == Settings.target_label }
  end

  private

  attr_reader :data

  def client
    @client ||= GitHubApi.new(repo, id)
  end
end
