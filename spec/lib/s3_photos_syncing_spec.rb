require 'spec_helper'
require 's3_photos_syncing'

describe S3PhotosSyncing do
  describe '.run' do
    let(:processor) do
      processor = mock
      processor.stub(:run)

      processor
    end

    it 'creates a S3PhotosSyncing::Processor' do
      S3PhotosSyncing::Processor.should_receive(:new).and_return(processor)
      S3PhotosSyncing.run({})
    end

    it 'calls #run on a S3PhotosSyncing::Processor' do
      S3PhotosSyncing::Processor.should_receive(:new).and_return(processor)
      processor.should_receive(:run)

      S3PhotosSyncing.run({})
    end
  end
end
