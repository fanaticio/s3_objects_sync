require 'spec_helper'
require 's3_photos_syncing/processor'

describe S3PhotosSyncing::Processor do
  context 'instance methods' do
    let(:configuration) { { buckets: { :source => 'awesome-bucket' }} }
    let(:processor)     { S3PhotosSyncing::Processor.new(configuration) }

    before(:each) { S3PhotosSyncing::Logger.stub(:info) }

    describe '#configure_aws' do
      it 'configures globally AWS' do
        authentication_mock = mock
        configuration.merge!({ 'authentication' => authentication_mock, 'other' => 'value' })
        ::AWS.should_receive(:config).with(authentication_mock)

        processor.configure_aws
      end
    end

    describe '#execute_asynchronously' do
      let(:executor) do
        executor = mock
        executor.stub(:execute)

        executor
      end

      before(:each) do
        S3PhotosSyncing::Processor.any_instance.stub(:configure_aws)
        processor.stub(:executor).and_return(executor)
      end

      it 'creates a FutureTask object with transfer' do
        transfer = mock
        FutureTask.should_receive(:new).with(transfer)

        processor.execute_asynchronously(transfer)
      end

      it 'calls #execute on executor with a FutureTask object' do
        future_task = mock
        FutureTask.stub(:new).and_return(future_task)
        executor.should_receive(:execute).with(future_task)

        processor.execute_asynchronously(mock)
      end
    end

    describe '#executor' do
      before(:each) { S3PhotosSyncing::Processor.any_instance.stub(:configure_aws) }

      it 'creates new Executors instance with number of threads based on options' do
        configuration[:max_threads] = 42

        Executors.should_receive(:newFixedThreadPool).with(42)
        processor.executor
      end
    end

    describe '#run' do
      let(:executor) do
        executor = mock
        executor.stub(:shutdown)

        executor
      end

      before(:each) do
        S3PhotosSyncing::Processor.any_instance.stub(:configure_aws)
        S3PhotosSyncing::AWS.stub(:objects_from).and_return([])
        processor.stub(:executor).and_return(executor)
      end

      it 'calls S3PhotosSyncing::AWS::objects_from' do
        processor.should_receive(:configure_aws)

        processor.run
      end

      it 'calls S3PhotosSyncing::AWS::objects_from' do
        S3PhotosSyncing::AWS.should_receive(:objects_from).with('awesome-bucket', 'photos')

        processor.run
      end

      it 'creates X S3PhotosSyncing::TransferAsynchronously' do
        S3PhotosSyncing::TransferAsynchronously.should_receive(:new).exactly(3).times
        S3PhotosSyncing::AWS.stub(:objects_from).and_return([mock, mock, mock])
        processor.stub(:execute_asynchronously)

        processor.run
      end

      it 'calls X times #execute_asynchronously' do
        S3PhotosSyncing::AWS.stub(:objects_from).and_return([mock, mock, mock])
        processor.should_receive(:execute_asynchronously).exactly(3).times

        processor.run
      end

      it 'calls #shutdown on the executor' do
        executor.should_receive(:shutdown)

        processor.run
      end
    end
  end
end
