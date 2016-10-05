class PullRequest
  def initialize(params)
    @data = JSON.parse(params)
  end

  def id
    data.dig('pull_request', 'number')
  end

  def repo
    data.dig('pull_request', 'repository', 'full_name')
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

  private

  attr_reader :data
end
