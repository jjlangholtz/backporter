require 'rails_helper'

describe PullRequestService do
  describe '.run' do
    it 'removes the target label' do
      pull_request = instance_double('PullRequest', :id => nil, :repo => nil, :html_url => nil)
      label = instance_double('Label', :name => 'backport/yes', :success => nil)
      comment = instance_double('Comment', :backport_failed? => false, :content => nil, :backport_sha => nil)
      gh_client = instance_double('GitHubApi', :add_label => nil, :comment => nil)
      google_client = instance_double('GoogleSheetsApi')

      allow(ENV).to receive(:fetch)
      allow(GitHubApi).to receive(:new) { gh_client }
      allow(GoogleSheetsApi).to receive(:new) { google_client }
      allow(google_client).to receive(:add_entry)

      expect(gh_client).to receive(:remove_label).with('backport/yes')

      described_class.run(pull_request, label, comment)
    end

    context 'when backport is successful' do
      it 'adds a new entry to the backport sheet' do
        pull_request = instance_double('PullRequest', :id => nil, :repo => nil, :html_url => 'https://github.com/jjlangholtz/backporter/pull/1')
        label = instance_double('Label', :name => 'backport/yes', :success => nil)
        comment = instance_double('Comment', :backport_failed? => false, :content => nil, :backport_sha => 'gitsha')
        gh_client = instance_double('GitHubApi', :add_label => nil, :comment => nil)
        google_client = instance_double('GoogleSheetsApi')

        allow(ENV).to receive(:fetch)
        allow(GitHubApi).to receive(:new) { gh_client }
        allow(gh_client).to receive(:remove_label).with('backport/yes')
        allow(GoogleSheetsApi).to receive(:new) { google_client }
        allow(Date).to receive(:current) { Date.new(2016, 10, 1) }

        expect(google_client).to receive(:add_entry).with(
          'https://github.com/jjlangholtz/backporter/pull/1',
          '2016-10-01',
          'gitsha'
        )

        described_class.run(pull_request, label, comment)
      end
    end

    context 'when backport has failed' do
      it 'creates a new github issue and assigns it to the pull request author' do
        pull_request = instance_double('PullRequest', :id => nil, :repo => nil)
        label = instance_double('Label', :name => 'backport/yes', :conflict => nil)
        comment = instance_double('Comment', :backport_failed? => true, :content => 'captured content')
        client = instance_double('GitHubApi', :add_label => nil, :comment => nil)

        allow(ENV).to receive(:fetch)
        allow(GitHubApi).to receive(:new) { client }
        allow(client).to receive(:remove_label).with('backport/yes')

        expect(client).to receive(:create_issue).with('Backport failed', 'captured content')
        described_class.run(pull_request, label, comment)
      end
    end
  end
end
