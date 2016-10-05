class PullRequestService
  def self.run(pull_request)
    new(pull_request).run
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

  attr_reader :repo, :id

  def remove_target_label
    client.remove_label(Settings.target_label)
  end

  def add_backported_label
    client.add_label(Settings.backport_label)
  end

  def add_git_log_comment
    client.comment(comment)
  end

  def comment
    <<~EOS
      Backported with no conflicts: #{`git rev-parse --short HEAD`}

      ```diff
      #{`git show`}
    EOS
  end

  def client
    @client ||= GitHubApi.new(repo, id)
  end
end
