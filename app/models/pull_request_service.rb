class PullRequestService
  def self.run(pull_request, label, comment)
    new(pull_request, label, comment).run
  end

  def initialize(pull_request, label, comment)
    @repo = pull_request.repo
    @id = pull_request.id
    @label = label
    @comment = comment
  end

  def run
    remove_target_label(label.name)
    add_backport_status_label(label)
    comment_on_pull_request
  end

  private

  attr_reader :repo, :id, :label, :comment

  def remove_target_label(name)
    client.remove_label(name)
  end

  def add_backport_status_label(label)
    name = conflict? ? label.conflict : label.success
    client.add_label(name)
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
