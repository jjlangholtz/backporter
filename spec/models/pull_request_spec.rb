require 'rails_helper'

describe PullRequest do
  let(:params) { JSON.parse(File.read(Rails.root.join('spec/fixtures/pull_request.json'))) }

  describe '#id' do
    it 'returns the id from the payload params' do
      pull_request = PullRequest.new(params)
      expect(pull_request.id).to eq 1
    end
  end

  describe '#repo' do
    it 'returns the repo from the payload params' do
      pull_request = PullRequest.new(params)
      expect(pull_request.repo).to eq 'jjlangholtz/backporter'
    end
  end

  describe '#user' do
    it 'returns the user from the payload params' do
      pull_request = PullRequest.new(params)
      expect(pull_request.user).to eq 'jjlangholtz'
    end
  end

  describe '#merge_commit_sha' do
    it 'returns the merge_commit_sha from the payload params' do
      pull_request = PullRequest.new(params)
      expect(pull_request.merge_commit_sha).to eq '123'
    end
  end

  describe '#merged?' do
    it 'returns true when the pull request is merged and closed' do
      pull_request = PullRequest.new(params)
      expect(pull_request).to be_merged
    end
  end

  describe '#includes_target_label?' do
    it 'returns true when the target label is included from the request to the labels endpoint' do
      client = instance_double('GitHubApi', :labels => [double('LabelResponse', :name => 'backport/yes')])
      allow(GitHubApi).to receive(:new) { client }
      allow(Label).to receive(:target_label_names) { %w(backport/yes) }
      allow(Label).to receive(:for) { instance_double('Label') }

      pull_request = PullRequest.new(params)

      expect(pull_request).to be_includes_target_label
    end
  end

  describe '#target_labels' do
    it 'returns a list of labels from the labels endpoint' do
      client = instance_double('GitHubApi', :labels => [double('LabelResponse', :name => 'backport/yes')])
      allow(GitHubApi).to receive(:new) { client }
      allow(Label).to receive(:target_label_names) { %w(backport/yes) }
      expect(Label).to receive(:for) { instance_double('Label') }

      pull_request = PullRequest.new(params)
      expect(pull_request.target_labels).to be_a Array
    end
  end
end
