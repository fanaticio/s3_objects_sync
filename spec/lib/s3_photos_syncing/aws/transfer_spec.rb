require 'spec_helper'
require 's3_photos_syncing/aws/transfer'

describe S3PhotosSyncing::AWS::Transfer do
  let(:object)   { mock }
  let(:transfer) { S3PhotosSyncing::AWS::Transfer.new(object, { from: 'awesome_bucket', to: 'another_bucket' }) }

  describe '#destination' do
    it 'returns destination from bucket_name' do
      destination  = mock
      buckets = { 'another_bucket' => destination, 'invalid_bucket' => mock }
      ::AWS::S3.any_instance.stub(:buckets).and_return(buckets)

      transfer.destination.should == destination
    end
  end

  describe '#destination_object' do
    it 'returns destination_object from destination bucket' do
      destination_object = mock
      objects            = { awesome_key: destination_object, invalid_key: mock }
      destination        = mock

      destination.stub(:objects).and_return(objects)
      object.stub(:key).and_return(:awesome_key)
      transfer.stub(:destination).and_return(destination)

      transfer.destination_object.should == destination_object
    end
  end

  describe '#run' do
    before(:each) do
      destination_object = mock
      source_object      = mock
      source_object.stub(:key).and_return('awesome-file')

      transfer.stub(:destination_object).and_return(destination_object)
      transfer.stub(:source_object).and_return(source_object)

      S3PhotosSyncing::Logger.stub(:error)
      S3PhotosSyncing::Logger.stub(:info)
    end

    context 'when source object is not valid' do
      it 'does not call #copy_from on destination_object' do
        transfer.stub(:valid_source_object?).and_return(false)
        transfer.destination_object.should_not_receive(:copy_from)

        transfer.run
      end
    end

    context 'when source object is valid' do
      context 'when destination_object already exists' do
        it 'does not call #copy_from on destination_object' do
          transfer.stub(:valid_source_object?).and_return(true)
          transfer.destination_object.stub(:exists?).and_return(true)
          transfer.destination_object.should_not_receive(:copy_from)

          transfer.run
        end
      end

      context 'when destination_object does not exist' do
        it 'calls #copy_from on destination_object' do
          source = mock

          transfer.stub(:source).and_return(source)
          transfer.stub(:valid_source_object?).and_return(true)
          transfer.destination_object.stub(:exists?).and_return(false)
          transfer.destination_object.should_receive(:copy_from).with('awesome-file', bucket: source, acl: :public_read)

          transfer.run
        end
      end
    end
  end

  describe '#source' do
    it 'returns source from bucket_name' do
      source  = mock
      buckets = { 'awesome_bucket' => source, 'invalid_bucket' => mock }
      ::AWS::S3.any_instance.stub(:buckets).and_return(buckets)

      transfer.source.should == source
    end
  end

  describe '#source_object' do
    it 'returns @object' do
      transfer.source_object.should == object
    end
  end

  describe '#valid_source_object?' do
    before(:each) { transfer.stub(:file_format).and_return(/\.ext$/i) }

    context 'when source_object has a valid extension' do
      it 'returns true' do
        source_object = mock
        source_object.stub(:key).and_return('awesome-file.ext')
        transfer.stub(:source_object).and_return(source_object)

        transfer.valid_source_object?.should == true
      end
    end

    context 'when source_object has an invalid extension' do
      it 'returns false' do
        source_object = mock
        source_object.stub(:key).and_return('awesome-file.txe')
        transfer.stub(:source_object).and_return(source_object)

        transfer.valid_source_object?.should == false
      end
    end
  end
end
