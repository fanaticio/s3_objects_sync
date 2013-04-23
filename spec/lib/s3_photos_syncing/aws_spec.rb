require 'spec_helper'
require 's3_photos_syncing/aws'

describe S3PhotosSyncing::AWS do
  describe '.all_objects_from' do
    let(:objects_mock) do
      objects_mock = mock
      objects_mock.stub(:all)

      objects_mock
    end

    it 'creates a S3PhotosSyncing::AWS::Objects with a bucket name' do
      S3PhotosSyncing::AWS::Objects.should_receive(:new).with('awesome_bucket')
      S3PhotosSyncing::AWS::Objects.stub(:new).and_return(objects_mock)

      S3PhotosSyncing::AWS.all_objects_from('awesome_bucket')
    end

    it 'calls #all on S3PhotosSyncing::AWS::Objects' do
      S3PhotosSyncing::AWS::Objects.stub(:new).and_return(objects_mock)
      objects_mock.should_receive(:all)

      S3PhotosSyncing::AWS.all_objects_from('awesome_bucket')
    end
  end

  describe '.objects_from' do
    context 'when there is no prefix parameter' do
      it 'calls .all_objects_from with bucket name' do
        S3PhotosSyncing::AWS.should_receive(:all_objects_from).with('awesome_bucket')

        S3PhotosSyncing::AWS.objects_from('awesome_bucket')
      end
    end

    context 'when there is prefix parameter' do
      it 'calls .objects_with_prefix_from with bucket name' do
        S3PhotosSyncing::AWS.should_receive(:objects_with_prefix_from).with('awesome_bucket', 'prefix')

        S3PhotosSyncing::AWS.objects_from('awesome_bucket', 'prefix')
      end
    end
  end

  describe '.objects_with_prefix_from' do
    let(:objects_mock) do
      objects_mock = mock
      objects_mock.stub(:all_with_prefix)

      objects_mock
    end

    it 'creates a S3PhotosSyncing::AWS::Objects with a bucket name' do
      S3PhotosSyncing::AWS::Objects.should_receive(:new).with('awesome_bucket')
      S3PhotosSyncing::AWS::Objects.stub(:new).and_return(objects_mock)

      S3PhotosSyncing::AWS.objects_with_prefix_from('awesome_bucket', 'prefix')
    end

    it 'calls #objects_with_prefix_from on S3PhotosSyncing::AWS::Objects with a prefix' do
      S3PhotosSyncing::AWS::Objects.stub(:new).and_return(objects_mock)
      objects_mock.should_receive(:all_with_prefix).with('prefix')

      S3PhotosSyncing::AWS.objects_with_prefix_from('awesome_bucket', 'prefix')
    end
  end

  describe '.transfer' do
    let(:transfer_mock) do
      transfer_mock = mock
      transfer_mock.stub(:run)

      transfer_mock
    end

    it 'creates a S3PhotosSyncing::AWS::Transfer with a bucket name and options' do
      S3PhotosSyncing::AWS::Transfer.should_receive(:new).with('awesome_bucket', { foo: 'bar' })
      S3PhotosSyncing::AWS::Transfer.stub(:new).and_return(transfer_mock)

      S3PhotosSyncing::AWS.transfer('awesome_bucket', { foo: 'bar' })
    end

    it 'calls #run on S3PhotosSyncing::AWS::Transfer with a prefix' do
      S3PhotosSyncing::AWS::Transfer.stub(:new).and_return(transfer_mock)
      transfer_mock.should_receive(:run)

      S3PhotosSyncing::AWS.transfer('awesome_bucket', { foo: 'bar' })
    end
  end
end

