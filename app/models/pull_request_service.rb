class PullRequestService
  def self.run(pull_request, comment)
    new(pull_request, comment).run
  end

  def initialize(pull_request, comment)
    @repo = pull_request.repo
    @id = pull_request.id
    @labels = pull_request.target_labels
    @comment = comment
  end

  def run
    labels.each do |label|
      remove_target_label(label.name)
      add_backport_status_label(label)
      comment_on_pull_request
    end
  end

  private

  attr_reader :repo, :id, :labels, :comment

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
