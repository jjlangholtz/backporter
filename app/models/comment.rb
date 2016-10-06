class Comment
  attr_reader :content

  def initialize(pull_request, label)
    @pull_request = pull_request
    @label = label
  end

  def capture_success
    @backport_status = :success
    @content = <<~EOS
      Backported to `#{branch}` with no conflicts: #{`git rev-parse --short HEAD`}

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
