require 'rails_helper'

describe PullRequestService do
  describe '.run' do
    it 'removes the target label' do
      pull_request = instance_double('PullRequest', :id => nil, :repo => nil)
      label = instance_double('Label', :name => 'backport/yes', :success => nil)
      comment = instance_double('Comment', :backport_failed? => false, :content => nil)
      client = instance_double('GitHubApi', :add_label => nil, :comment => nil)

      allow(ENV).to receive(:fetch)
      allow(GitHubApi).to receive(:new) { client }

      expect(client).to receive(:remove_label).with('backport/yes')

      described_class.run(pull_request, label, comment)
    end
  end
end
