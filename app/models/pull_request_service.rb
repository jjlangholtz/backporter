class PullRequestService
  def self.run(pull_request, comment)
    new(pull_request, comment).run
  end

  def initialize(pull_request, comment)
    @repo = pull_request.repo
    @id = pull_request.id
    @comment = comment
  end

  def run
    remove_target_label
    add_backport_status_label
    comment_on_pull_request
  end

  private

  attr_reader :repo, :id, :comment

  def remove_target_label
    client.remove_label(Settings.target_label)
  end

  def add_backport_status_label
    label = conflict? ? Settings.conflict_label : Settings.backport_label
    client.add_label(label)
  end

  def conflict?
    comment.backport_failed?
  end

  def comment_on_pull_request
    client.comment(comment.content)
  end

  def client
    @client ||= GitHubApi.new(repo, id)
  end
end
