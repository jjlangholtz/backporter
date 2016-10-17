require 'rails_helper'

describe GoogleSheetsApi do
  context 'when ENV["GOOGLE_SHEET_ID"] is not set' do
    it 'raises an exception' do
      expect { described_class.new }.to raise_error(StandardError, 'set GOOGLE_SHEET_ID env var')
    end
  end

  context 'when ENV["GOOGLE_TOKEN"] is not set' do
    it 'raises an exception' do
      stub_const('ENV', ENV.to_hash.merge('GOOGLE_SHEET_ID' => ''))
      expect { described_class.new }.to raise_error(StandardError, 'set GOOGLE_TOKEN env var')
    end
  end

  describe '#add_entry' do
    it 'makes a POST request to the google sheets api' do
      stub_request(:post, 'https://sheets.googleapis.com/v4/spreadsheets/1/values/A1:append?valueInputOption=RAW')
      stub_const('ENV', ENV.to_hash.merge('GOOGLE_SHEET_ID' => '1', 'GOOGLE_TOKEN' => '123xyz'))

      client = described_class.new
      client.add_entry('foo', 'bar', 'baz')

      expect(a_request(:post, %r{spreadsheets/1/values/A1:append})
        .with(:body    => '{"values":[["foo","bar","baz"]]}',
              :headers => { 'Authorization' => 'Bearer 123xyz' })).to have_been_made
    end
  end
end
