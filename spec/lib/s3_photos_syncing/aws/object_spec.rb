require 'spec_helper'
require 's3_photos_syncing/aws/object'

describe S3PhotosSyncing::AWS::Object do
  let(:object) { S3PhotosSyncing::AWS::Object.new('awesome_bucket') }

  describe '#all' do
    it 'calls #objects on #source' do
      source = mock
      source.should_receive(:objects)
      object.stub(:source).and_return(source)

      object.all
    end
  end

  describe '#all_with_prefix' do
    it 'calls #with_prefix on #all' do
      all = mock
      all.should_receive(:with_prefix).with('awesome-prefix')
      object.stub(:all).and_return(all)

      object.all_with_prefix('awesome-prefix')
    end
  end

  describe '#source' do
    it 'returns source from bucket_name' do
      source  = mock
      buckets = { 'invalid_bucket' => mock, 'awesome_bucket' => source }
      ::AWS::S3.any_instance.stub(:buckets).and_return(buckets)

      object.source.should == source
    end
  end
end
