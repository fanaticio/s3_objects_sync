require 'spec_helper'
require 's3_photos_syncing/logger'

describe S3PhotosSyncing::Logger do
  describe '.error' do
    it 'calls .write_message with :info and message as parameters' do
      S3PhotosSyncing::Logger.should_receive(:write_message).with(:error, 'Awesome message')

      S3PhotosSyncing::Logger.error('Awesome message')
    end
  end

  describe '.info' do
    it 'calls .write_message with :info and message as parameters' do
      S3PhotosSyncing::Logger.should_receive(:write_message).with(:info, 'Awesome message')

      S3PhotosSyncing::Logger.info('Awesome message')
    end
  end

  describe '.write_message' do
    it 'calls .format_message with type and message as parameters' do
      S3PhotosSyncing::Logger.should_receive(:format_message).with(:custom_type, 'Awesome message')

      S3PhotosSyncing::Logger.write_message(:custom_type, 'Awesome message')
    end

    it 'puts the formatted_message' do
      S3PhotosSyncing::Logger.stub(:format_message) { |type, message| "#{type} - #{message}" }
      S3PhotosSyncing::Logger.should_receive(:puts).with('custom_type - Awesome message')

      S3PhotosSyncing::Logger.write_message(:custom_type, 'Awesome message')
    end
  end

  describe '.format_message' do
    it 'returns formatted message' do
      Time.stub(:now).and_return(Time.parse('2012-01-12 13:37:00'))

      expected_message = '[2012-12-01 - 13:37:00] - custom_type - Awesome message'
      S3PhotosSyncing::Logger.format_message(:custom_type, 'Awesome message').should == expected_message
    end
  end
end
