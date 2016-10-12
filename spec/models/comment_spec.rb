require 'rails_helper'

describe Comment do
  describe '#capture_success' do
    it 'contains descriptive content from the backport' do
      pull_request = instance_double('PullRequest')
      label = instance_double('Label', :branch => 'backports')

      allow_any_instance_of(Object).to receive(:`).with('git rev-parse --short HEAD') { 'abc123' }
      allow_any_instance_of(Object).to receive(:`).with('git show') { 'redacted git show' }

      comment = described_class.new(pull_request, label)
      comment.capture_success

      expect(comment).to_not be_backport_failed
      expect(comment.content).to eq <<~EOS
        Backported to `backports` with no conflicts: abc123

        ```diff
        redacted git show
      EOS
    end
  end

  describe '#capture_conflict' do
    it 'contains descriptive content from the backport conflict' do
      pull_request = instance_double('PullRequest', :user => 'josh')
      label = instance_double('Label', :branch => 'backports')

      allow_any_instance_of(Object).to receive(:`).with('git diff') { 'redacted git diff' }

      comment = described_class.new(pull_request, label)
      comment.capture_conflict

      expect(comment).to be_backport_failed
      expect(comment.content).to eq <<~EOS
        Backport to `backports` failed with conflicts, @josh please review:

        ```diff
        redacted git diff
      EOS
    end
  end
end
