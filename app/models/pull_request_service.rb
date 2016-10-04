class PullRequestService
  def self.run(pull_request)
    new(pull_request)
  end

  def initialize(pull_request)
    @repo = pull_request.repo
    @id = pull_request.id
  end

  def run
    remove_target_label
    add_backported_label
    add_git_log_comment
  end

  private

  attr_reader :id

  # TODO: pull target label names from a configuration file
  def remove_target_label
    client.remove_label('Yes')
  end

  def add_backported_label
    client.add_label('Backported')
  end

  def add_git_log_comment
    client.comment(`git show`)
  end

  def client
    @client ||= GitHubApi.new(repo, id)
  end
end
