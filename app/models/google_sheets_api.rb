require 'google/apis/sheets_v4'

class GoogleSheetsApi
  def initialize
    @client = Google::Apis::SheetsV4::SheetsService.new
    @spreadsheet_id = ENV.fetch('GOOGLE_SHEET_ID') { raise 'set GOOGLE_SHEET_ID env var' }
    @bearer_token = ENV.fetch('GOOGLE_TOKEN') { raise 'set GOOGLE_TOKEN env var' }
  end

  def add_entry(*values)
    client.append_spreadsheet_value(
      spreadsheet_id,
      'A1',
      Google::Apis::SheetsV4::ValueRange.from_json({ :values => [values] }.to_json),
      :value_input_option => 'RAW',
      :options            => { :header => { 'Authorization' => "Bearer #{bearer_token}" } }
    )
  end

  private

  attr_reader :client, :bearer_token, :spreadsheet_id
end
