require 'rails_helper'

describe BackportService do
  describe '.run' do
    context 'when backport is successful' do
      it 'makes a series of system calls to complete the backport' do
        pull_request = instance_double('PullRequest', :merge_commit_sha => 'abc', :user => nil)
        label = instance_double('Label', :branch => 'backports')

        expect_any_instance_of(Object).to receive(:system).with('git fetch -p')
        expect_any_instance_of(Object).to receive(:system).with('git checkout backports')
        expect_any_instance_of(Object).to receive(:system).with('git cherry-pick -x -m 1 abc') { true }
        expect_any_instance_of(Object).to receive(:system).with('git push origin backports')

        described_class.run(pull_request, label)
      end
    end

    context 'when backport fails' do
      it 'stashes cherry picked commits instead' do
        pull_request = instance_double('PullRequest', :merge_commit_sha => 'abc', :user => nil)
        label = instance_double('Label', :branch => 'backports')

        expect_any_instance_of(Object).to receive(:system).with('git fetch -p')
        expect_any_instance_of(Object).to receive(:system).with('git checkout backports')
        expect_any_instance_of(Object).to receive(:system).with('git cherry-pick -x -m 1 abc') { false }
        expect_any_instance_of(Object).to receive(:system).with('git add -A && git stash')

        described_class.run(pull_request, label)
      end
    end
  end
end
