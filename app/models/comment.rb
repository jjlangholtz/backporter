class Comment
  attr_reader :content

  def capture_success
    @backport_status = :success
    @content = <<~EOS
      Backported with no conflicts: #{`git rev-parse --short HEAD`}

      ```diff
      #{`git show`}
    EOS
  end

  def capture_conflict
    @backport_status = :conflict
    @content = <<~EOS
      Backport failed with conflicts:

      ```diff
      #{`git diff`}
    EOS
  end

  def backport_failed?
    @backport_status == :conflict
  end
end
