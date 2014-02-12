require 'spec_helper'
require 's3_objects_sync/aws/transfer'

describe S3ObjectsSync::AWS::Transfer do
  let(:object)   { double }
  let(:transfer) { S3ObjectsSync::AWS::Transfer.new(object, options) }
  let(:options)  { { from: 'awesome_bucket', to: 'another_bucket' } }

  describe '#can_copy?' do
    context 'when force is set to "true"' do
      before(:each) do
        options[:force] = true
      end

      context 'when destination_object exists' do
        it 'returns true' do
          transfer.stub_chain(:destination_object, :exists?).and_return(true)
          transfer.can_copy?.should == true
        end
      end

      context 'when destination_object does not exist' do
        it 'returns true' do
          transfer.stub_chain(:destination_object, :exists?).and_return(false)
          transfer.can_copy?.should == true
        end
      end
    end

    context 'when force is set to "false"' do
      before(:each) do
        options[:force] = false
      end

      context 'when destination_object exists' do
        it 'returns false' do
          transfer.stub_chain(:destination_object, :exists?).and_return(true)
          transfer.can_copy?.should == false
        end
      end

      context 'when destination_object does not exist' do
        it 'returns true' do
          transfer.stub_chain(:destination_object, :exists?).and_return(false)
          transfer.can_copy?.should == true
        end
      end
    end
  end

  describe '#destination' do
    it 'returns destination from bucket_name' do
      destination  = double
      buckets = { 'another_bucket' => destination, 'invalid_bucket' => double }
      ::AWS::S3.any_instance.stub(:buckets).and_return(buckets)

      transfer.destination.should == destination
    end
  end

  describe '#destination_object' do
    it 'returns destination_object from destination bucket' do
      destination_object = double
      objects            = { awesome_key: destination_object, invalid_key: double }
      destination        = double

      destination.stub(:objects).and_return(objects)
      object.stub(:key).and_return(:awesome_key)
      transfer.stub(:destination).and_return(destination)

      transfer.destination_object.should == destination_object
    end
  end

  describe '#run' do
    before(:each) do
      destination_object = double
      source_object      = double
      source_object.stub(:key).and_return('awesome-file')

      transfer.stub(:destination_object).and_return(destination_object)
      transfer.stub(:source_object).and_return(source_object)

      S3ObjectsSync::Logger.stub(:error)
      S3ObjectsSync::Logger.stub(:info)
    end

    context 'when source object is not valid' do
      it 'does not call #copy_from on destination_object' do
        transfer.stub(:valid_source_object?).and_return(false)
        transfer.destination_object.should_not_receive(:copy_from)

        transfer.run
      end
    end

    context 'when source object is valid' do
      before(:each) { transfer.stub(:valid_source_object?).and_return(true) }

      context 'when destination_object can not be copied' do
        it 'does not call #copy_from on destination_object' do
          transfer.stub(:can_copy?).and_return(false)
          transfer.destination_object.should_not_receive(:copy_from)

          transfer.run
        end
      end

      context 'when destination_object can be copied' do
        it 'calls #copy_from on destination_object' do
          source = double
          transfer.stub(:source).and_return(source)
          transfer.stub(:can_copy?).and_return(true)
          transfer.destination_object.should_receive(:copy_from).with('awesome-file', bucket: source, acl: :public_read)

          transfer.run
        end
      end

      context 'when copy raises an error' do
        it 'logs the error' do
          source = double
          transfer.stub(:source).and_return(source)
          transfer.stub(:can_copy?).and_return(true)
          transfer.destination_object.stub(:copy_from).and_raise(Exception)

          S3ObjectsSync::Logger.should_receive(:error)
          transfer.run
        end
      end
    end
  end

  describe '#source' do
    it 'returns source from bucket_name' do
      source  = double
      buckets = { 'awesome_bucket' => source, 'invalid_bucket' => double }
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
    before(:each) { options[:format] = '\.ext$' }

    context 'when source_object has a valid extension' do
      it 'returns true' do
        source_object = double
        source_object.stub(:key).and_return('awesome-file.ext')
        transfer.stub(:source_object).and_return(source_object)

        transfer.valid_source_object?.should == true
      end
    end

    context 'when source_object has an invalid extension' do
      it 'returns false' do
        source_object = double
        source_object.stub(:key).and_return('awesome-file.txe')
        transfer.stub(:source_object).and_return(source_object)

        transfer.valid_source_object?.should == false
      end
    end
  end
end
