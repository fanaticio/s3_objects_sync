require 'spec_helper'
require 's3_objects_sync/aws'

describe S3ObjectsSync::AWS do
  describe '.all_objects_from' do
    let(:object_double) do
      object_double = double
      object_double.stub(:all)

      object_double
    end

    it 'creates a S3ObjectsSync::AWS::Object with a bucket name' do
      S3ObjectsSync::AWS::Object.should_receive(:new).with('awesome_bucket')
      S3ObjectsSync::AWS::Object.stub(:new).and_return(object_double)

      S3ObjectsSync::AWS.all_objects_from('awesome_bucket')
    end

    it 'calls #all on S3ObjectsSync::AWS::Object' do
      S3ObjectsSync::AWS::Object.stub(:new).and_return(object_double)
      object_double.should_receive(:all)

      S3ObjectsSync::AWS.all_objects_from('awesome_bucket')
    end
  end

  describe '.objects_from' do
    context 'when there is no prefix parameter' do
      it 'calls .all_objects_from with bucket name' do
        S3ObjectsSync::AWS.should_receive(:all_objects_from).with('awesome_bucket')

        S3ObjectsSync::AWS.objects_from('awesome_bucket')
      end
    end

    context 'when there is prefix parameter' do
      it 'calls .objects_with_prefix_from with bucket name' do
        S3ObjectsSync::AWS.should_receive(:objects_with_prefix_from).with('awesome_bucket', 'prefix')

        S3ObjectsSync::AWS.objects_from('awesome_bucket', 'prefix')
      end
    end
  end

  describe '.objects_with_prefix_from' do
    let(:object_double) do
      object_double = double
      object_double.stub(:all_with_prefix)

      object_double
    end

    it 'creates a S3ObjectsSync::AWS::Object with a bucket name' do
      S3ObjectsSync::AWS::Object.should_receive(:new).with('awesome_bucket')
      S3ObjectsSync::AWS::Object.stub(:new).and_return(object_double)

      S3ObjectsSync::AWS.objects_with_prefix_from('awesome_bucket', 'prefix')
    end

    it 'calls #objects_with_prefix_from on S3ObjectsSync::AWS::Object with a prefix' do
      S3ObjectsSync::AWS::Object.stub(:new).and_return(object_double)
      object_double.should_receive(:all_with_prefix).with('prefix')

      S3ObjectsSync::AWS.objects_with_prefix_from('awesome_bucket', 'prefix')
    end
  end

  describe '.transfer' do
    let(:transfer_double) do
      transfer_double = double
      transfer_double.stub(:run)

      transfer_double
    end

    it 'creates a S3ObjectsSync::AWS::Transfer with a bucket name and options' do
      S3ObjectsSync::AWS::Transfer.should_receive(:new).with('awesome_bucket', { foo: 'bar' })
      S3ObjectsSync::AWS::Transfer.stub(:new).and_return(transfer_double)

      S3ObjectsSync::AWS.transfer('awesome_bucket', { foo: 'bar' })
    end

    it 'calls #run on S3ObjectsSync::AWS::Transfer with a prefix' do
      S3ObjectsSync::AWS::Transfer.stub(:new).and_return(transfer_double)
      transfer_double.should_receive(:run)

      S3ObjectsSync::AWS.transfer('awesome_bucket', { foo: 'bar' })
    end
  end
end

