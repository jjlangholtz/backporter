require 'rails_helper'

describe Label do
  describe '.target_label_names' do
    it 'returns the key names from the label configuration' do
      allow(YAML).to receive(:load_file).and_return(:'backport/yes' => {
                                                      :branch   => 'backports',
                                                      :conflict => 'backport/conflict',
                                                      :success  => 'backport/backported'
                                                    })

      expect(described_class.target_label_names).to eq %w(backport/yes)
    end
  end

  describe '.label_store' do
    it 'returns the labels from configuration' do
      allow(YAML).to receive(:load_file).and_return(:'backport/yes' => {
                                                      :branch   => 'backports',
                                                      :conflict => 'backport/conflict',
                                                      :success  => 'backport/backported'
                                                    })

      expect(described_class.label_store[:'backport/yes']).to include(
        :branch   => 'backports',
        :conflict => 'backport/conflict',
        :success  => 'backport/backported'
      )
    end
  end

  describe '.for' do
    it 'returns a new lable with properties from the store' do
      allow(YAML).to receive(:load_file).and_return(:'backport/yes' => {
                                                      :branch   => 'backports',
                                                      :conflict => 'backport/conflict',
                                                      :success  => 'backport/backported'
                                                    })

      label = described_class.for('backport/yes')

      expect(label.name).to eq 'backport/yes'
      expect(label.branch).to eq 'backports'
      expect(label.conflict).to eq 'backport/conflict'
      expect(label.success).to eq 'backport/backported'
    end
  end
end
