class BackportService
  def self.run(pull_request, label)
    new(pull_request, label).run
  end

  def initialize(pull_request, label)
    @sha = pull_request.merge_commit_sha
    @label = label
  end

  def run
    fetch_latest
    checkout
    cherry_pick
  end

  private

  attr_reader :label, :sha

  def fetch_latest
    system('git fetch -p')
  end

  def checkout
    system("git checkout #{label.branch}")
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
    system("git push origin #{label.branch}")
  end

  def stash_changes
    system("git add -A && git stash")
  end
end
