require 'spec_helper'
require 's3_objects_sync/logger'

describe S3ObjectsSync::Logger do
  describe '.error' do
    it 'calls .write_message with :info and message as parameters' do
      S3ObjectsSync::Logger.should_receive(:write_message).with(:error, 'Awesome message')

      S3ObjectsSync::Logger.error('Awesome message')
    end
  end

  describe '.info' do
    it 'calls .write_message with :info and message as parameters' do
      S3ObjectsSync::Logger.should_receive(:write_message).with(:info, 'Awesome message')

      S3ObjectsSync::Logger.info('Awesome message')
    end
  end

  describe '.write_message' do
    it 'calls .format_message with type and message as parameters' do
      S3ObjectsSync::Logger.should_receive(:format_message).with(:custom_type, 'Awesome message')

      S3ObjectsSync::Logger.write_message(:custom_type, 'Awesome message')
    end

    it 'puts the formatted_message' do
      S3ObjectsSync::Logger.stub(:format_message) { |type, message| "#{type} - #{message}" }
      S3ObjectsSync::Logger.should_receive(:puts).with('custom_type - Awesome message')

      S3ObjectsSync::Logger.write_message(:custom_type, 'Awesome message')
    end
  end

  describe '.format_message' do
    it 'returns formatted message' do
      Time.stub(:now).and_return(Time.parse('2012-01-12 13:37:00'))

      expected_message = '[2012-12-01 - 13:37:00] - custom_type - Awesome message'
      S3ObjectsSync::Logger.format_message(:custom_type, 'Awesome message').should == expected_message
    end
  end
end
