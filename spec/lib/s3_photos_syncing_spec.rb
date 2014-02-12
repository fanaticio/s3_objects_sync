require 'spec_helper'
require 's3_objects_sync'

describe S3ObjectsSync do
  describe '.run' do
    let(:processor) do
      processor = double
      processor.stub(:run)

      processor
    end

    it 'creates a S3ObjectsSync::Processor' do
      S3ObjectsSync::Processor.should_receive(:new).and_return(processor)
      S3ObjectsSync.run({})
    end

    it 'calls #run on a S3ObjectsSync::Processor' do
      S3ObjectsSync::Processor.should_receive(:new).and_return(processor)
      processor.should_receive(:run)

      S3ObjectsSync.run({})
    end
  end
end
