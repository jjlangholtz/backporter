class PullRequestService
  def self.run(pull_request, label, comment)
    new(pull_request, label, comment).run
  end

  def initialize(pull_request, label, comment)
    @pull_request = pull_request
    @label = label
    @comment = comment
  end

  def run
    remove_target_label(label.name)
    add_backport_status_label(label)
    comment_on_pull_request
    create_backport_conflict_issue if conflict?
  end

  private

  attr_reader :pull_request, :label, :comment

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

  def create_backport_conflict_issue
    client.create_issue('Backport failed', comment.content)
  end

  def comment_on_pull_request
    client.comment(comment.content)
  end

  def client
    @client ||= GitHubApi.new(pull_request)
  end
end
