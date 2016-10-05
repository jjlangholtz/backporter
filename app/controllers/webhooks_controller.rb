class WebhooksController < ApplicationController
  def create
    if pull_request.merged?
      BackportService.run(pull_request)
      PullRequestService.run(pull_request)
    elsif pull_request.labeled?
    end

    head :ok
  end

  private

  def pull_request
    @pull_request ||= PullRequest.new(params)
  end
end
