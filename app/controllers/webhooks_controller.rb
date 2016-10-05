class WebhooksController < ApplicationController
  REPO = '/Users/jlanghol/repos/jjlangholtz/backporter'.freeze # TODO: figure out where to store git repos

  def create
    if pull_request.merged? && pull_request.includes_target_label?
      Dir.chdir(REPO) do
        BackportService.run(pull_request)
        PullRequestService.run(pull_request)
      end
    elsif pull_request.labeled?
      # TODO: Persist PR with labels
    end

    head :ok
  end

  private

  def pull_request
    @pull_request ||= PullRequest.new(params.require(:webhook))
  end
end
