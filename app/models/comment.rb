class Comment
  attr_reader :content, :backport_sha

  def initialize(pull_request, label)
    @pull_request = pull_request
    @label = label
  end

  def capture_success
    @backport_status = :success
    @backport_sha = `git rev-parse HEAD`
    @content = <<~EOS
      Backported to `#{branch}` with no conflicts: #{backport_sha}

      ```diff
      #{`git show`}
    EOS
  end

  def capture_conflict
    @backport_status = :conflict
    @content = <<~EOS
      Backport to `#{branch}` failed with conflicts, @#{user} please review:

      ```diff
      #{`git diff`}
    EOS
  end

  def backport_failed?
    @backport_status == :conflict
  end

  private

  attr_reader :pull_request, :label

  def branch
    label.branch
  end

  def user
    pull_request.user
  end
end
