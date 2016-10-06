class BackportService
  def self.run(pull_request)
    new(pull_request).run
  end

  def initialize(pull_request)
    @sha = pull_request.merge_commit_sha
    @labels = pull_request.target_labels
  end

  def run
    labels.each do |label|
      fetch_latest
      checkout(label.branch)
      cherry_pick(label.branch)
    end
  end

  private

  attr_reader :labels, :sha

  def fetch_latest
    system('git fetch -p')
  end

  def checkout(branch)
    system("git checkout #{branch}")
  end

  def cherry_pick(branch)
    Comment.new.tap do |comment|
      if system("git cherry-pick -x -m 1 #{sha}")
        comment.capture_success
        push_changes(branch)
      else
        comment.capture_conflict
        stash_changes
      end
    end
  end

  def push_changes(branch)
    system("git push origin #{branch}")
  end

  def stash_changes
    system("git add -A && git stash")
  end
end
