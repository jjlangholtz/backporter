class WebhooksController < ApplicationController
  def create
    return head(:internal_server_error) unless valid_signature?

    if pull_request.merged? && pull_request.includes_target_label?
      Dir.chdir('/Users/jlanghol/repos/jjlangholtz/backporter') do
        pull_request.target_labels.each do |label|
          comment = BackportService.run(pull_request, label)
          PullRequestService.run(pull_request, label, comment)
        end
      end
    end

    head :ok
  end

  private

  def pull_request
    @pull_request ||= PullRequest.new(params.require(:webhook))
  end

  def valid_signature?
    digest = OpenSSL::Digest.new('sha1')
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(digest, ENV['SECRET_TOKEN'], request.body.read)
    Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end
end
