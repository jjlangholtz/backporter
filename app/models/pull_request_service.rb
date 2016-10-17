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
    if conflict?
      create_backport_conflict_issue
    else
      add_entry_to_backlog_sheet
    end
  end

  private

  attr_reader :pull_request, :label, :comment

  def remove_target_label(name)
    gh_client.remove_label(name)
  end

  def add_backport_status_label(label)
    name = conflict? ? label.conflict : label.success
    gh_client.add_label(name)
  end

  def conflict?
    comment.backport_failed?
  end

  def comment_on_pull_request
    gh_client.comment(comment.content)
  end

  def create_backport_conflict_issue
    gh_client.create_issue('Backport failed', comment.content)
  end

  def add_entry_to_backlog_sheet
    google_client.add_entry(pull_request.html_url, Date.current.to_s, comment.backport_sha)
  end

  def gh_client
    @gh_client ||= GitHubApi.new(pull_request)
  end

  def google_client
    @google_client ||= GoogleSheetsApi.new
  end
end
