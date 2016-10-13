require 'rails_helper'

describe 'Github webhook' do
  context 'with an invalid signature' do
    it 'returns an internal server error' do
      stub_const('ENV', ENV.to_hash.merge('SECRET_TOKEN' => ''))

      post '/webhooks', :headers => { 'HTTP_X_HUB_SIGNATURE' => 'invalid' }

      expect(response).to have_http_status(:internal_server_error)
    end
  end

  context 'with a valid signature' do
    it 'returns an ok response' do
      allow(PullRequest).to receive(:new) { instance_double('PullRequest', :merged? => false) }
      allow(Rack::Utils).to receive(:secure_compare) { true }
      stub_const('ENV', ENV.to_hash.merge('SECRET_TOKEN' => 'valid'))

      post '/webhooks',
           :params  => { :webhook => 'fake message' },
           :headers => { 'HTTP_X_HUB_SIGNATURE' => 'sha1=123' }

      expect(response).to have_http_status(:ok)
    end

    context 'with a merged pull request that includes a target label' do
      it 'returns an ok response and invokes the services' do
        label = instance_double('Label')
        comment = instance_double('Comment')
        pull_request = instance_double(
          'PullRequest',
          :merged?                => true,
          :includes_target_label? => true,
          :target_labels          => [label]
        )

        allow(PullRequest).to receive(:new) { pull_request }
        allow(Rack::Utils).to receive(:secure_compare) { true }
        allow(Dir).to receive(:chdir).and_yield
        stub_const('ENV', ENV.to_hash.merge('SECRET_TOKEN' => 'valid'))

        expect(BackportService).to receive(:run).with(pull_request, label) { comment }
        expect(PullRequestService).to receive(:run).with(pull_request, label, comment)

        post '/webhooks',
             :params  => { :webhook => 'fake message' },
             :headers => { 'HTTP_X_HUB_SIGNATURE' => 'sha1=123' }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
