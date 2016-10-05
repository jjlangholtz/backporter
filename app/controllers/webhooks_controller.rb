class WebhooksController < ApplicationController
  def create
    if pull_request.merged? && pull_request.includes_target_label?
      BackportService.run(pull_request)
      PullRequestService.run(pull_request)
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
