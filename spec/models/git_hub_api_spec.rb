require 'rails_helper'

describe GitHubApi do
  context 'when ENV["GH_TOKEN"] is not set' do
    it 'raises an exception' do
      expect { described_class.new('', '') }.to raise_error(StandardError, 'set GH_TOKEN env var')
    end
  end

  describe '#labels' do
    it 'makes a GET request to the github labels endpoint' do
      allow(ENV).to receive(:fetch)
      stub_request(:get, 'https://api.github.com/repos/jjlangholtz/backporter/issues/1/labels?per_page=100')

      client = described_class.new('jjlangholtz/backporter', '1')
      client.labels

      expect(a_request(:get, %r{jjlangholtz/backporter/issues/1/labels})).to have_been_made
    end
  end

  describe '#remove_label' do
    it 'makes a DELETE request to the github labels endpoint' do
      allow(ENV).to receive(:fetch)
      stub_request(:delete, 'https://api.github.com/repos/jjlangholtz/backporter/issues/1/labels/backport/yes')

      client = described_class.new('jjlangholtz/backporter', '1')
      client.remove_label('backport/yes')

      expect(a_request(:delete, %r{jjlangholtz/backporter/issues/1/labels/backport/yes})).to have_been_made
    end
  end

  describe '#add_label' do
    it 'makes a POST request to the github labels endpoint' do
      allow(ENV).to receive(:fetch)
      stub_request(:post, 'https://api.github.com/repos/jjlangholtz/backporter/issues/1/labels')

      client = described_class.new('jjlangholtz/backporter', '1')
      client.add_label('backported')

      expect(a_request(:post, %r{jjlangholtz/backporter/issues/1/labels})
        .with(:body => '["backported"]')).to have_been_made
    end
  end

  describe '#comment' do
    it 'makes a POST request to the github comments endpoint' do
      allow(ENV).to receive(:fetch)
      stub_request(:post, 'https://api.github.com/repos/jjlangholtz/backporter/issues/1/comments')

      client = described_class.new('jjlangholtz/backporter', '1')
      client.comment('Hello world')

      expect(a_request(:post, %r{jjlangholtz/backporter/issues/1/comments})
        .with(:body => '{"body":"Hello world"}')).to have_been_made
    end
  end
end
