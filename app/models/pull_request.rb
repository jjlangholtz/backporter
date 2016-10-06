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

  def labeled?
    data['action'] == 'labeled'
  end

  def includes_target_label?
    target_labels.present?
  end

  def target_labels
    labels.select { |label| label.in?(Label.target_label_names) }.map { |name| Label.for(name) }
  end

  private

  attr_reader :data

  def labels
    @labels ||= client.labels.map(&:name)
  end

  def client
    @client ||= GitHubApi.new(repo, id)
  end
end
