class BackportService
  def self.run(pull_request)
    new(pull_request.repo, pull_request.target_branch, pull_request.sha).run
  end

  def initialize(repo, target_branch, sha)
    @repo = repo
    @target_branch = target_branch
    @sha = sha
  end

  def run
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
