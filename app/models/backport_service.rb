class BackportService
  def self.run(pull_request)
    new(pull_request.merge_commit_sha).run
  end

  def initialize(sha)
    @target_branch = Settings.target_branch
    @sha = sha
  end

  def run
    fetch_latest
    checkout_target_branch
    cherry_pick
  end

  private

  attr_reader :target_branch, :sha

  def fetch_latest
    system('git fetch -p')
  end

  def checkout_target_branch
    system("git checkout #{target_branch}")
  end

  def cherry_pick
    Comment.new.tap do |comment|
      if system("git cherry-pick -x -m 1 #{sha}")
        comment.capture_success
        push_changes
      else
        comment.capture_conflict
        stash_changes
      end
    end
  end

  def push_changes
    system("git push origin #{target_branch}")
  end

  def stash_changes
    system("git add -A && git stash")
  end
end
