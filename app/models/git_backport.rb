class GitBackport
  def initialize(repo, target_branch, sha)
    @repo = repo
    @target_branch = target_branch
    @sha = sha
  end

  def call
    Dir.chdir(repo) do
      fetch_latest
      checkout_target_branch
      cherry_pick
    end
  end

  private

  attr_reader :repo, :target_branch, :sha

  def fetch_latest
    system('git fetch -p')
  end

  def checkout_target_branch
    system("git checkout #{target_branch}")
  end

  def cherry_pick
    system("git cherry-pick -x -m 1 #{sha}")
  end
end
