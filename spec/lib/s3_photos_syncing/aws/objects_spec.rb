require 'spec_helper'
require 's3_photos_syncing/aws/objects'

describe S3PhotosSyncing::AWS::Objects do
  let(:objects) { S3PhotosSyncing::AWS::Objects.new('awesome_bucket') }

  describe '#all' do
    it 'calls #objects on #source' do
      source = mock
      source.should_receive(:objects)
      objects.stub(:source).and_return(source)

      objects.all
    end
  end

  describe '#all_with_prefix' do
    it 'calls #with_prefix on #all' do
      all = mock
      all.should_receive(:with_prefix).with('awesome-prefix')
      objects.stub(:all).and_return(all)

      objects.all_with_prefix('awesome-prefix')
    end
  end

  describe '#source' do
    it 'returns source from bucket_name' do
      source  = mock
      buckets = { 'invalid_bucket' => mock, 'awesome_bucket' => source }
      ::AWS::S3.any_instance.stub(:buckets).and_return(buckets)

      objects.source.should == source
    end
  end
end
