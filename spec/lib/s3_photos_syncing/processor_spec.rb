require 'spec_helper'
require 's3_objects_sync/processor'

describe S3ObjectsSync::Processor do
  context 'instance methods' do
    let(:configuration) { { buckets: { :source => 'awesome-bucket' }} }
    let(:processor)     { S3ObjectsSync::Processor.new(configuration) }

    before(:each) { S3ObjectsSync::Logger.stub(:info) }

    describe '#execute_asynchronously' do
      let(:executor) do
        executor = double
        executor.stub(:execute)

        executor
      end

      before(:each) do
        processor.stub(:executor).and_return(executor)
      end

      it 'creates a FutureTask object with transfer' do
        transfer = double
        FutureTask.should_receive(:new).with(transfer)

        processor.execute_asynchronously(transfer)
      end

      it 'calls #execute on executor with a FutureTask object' do
        future_task = double
        FutureTask.stub(:new).and_return(future_task)
        executor.should_receive(:execute).with(future_task)

        processor.execute_asynchronously(double)
      end
    end

    describe '#executor' do
      it 'creates new Executors instance with number of threads based on options' do
        configuration[:max_threads] = 42

        Executors.should_receive(:newFixedThreadPool).with(42)
        processor.executor
      end
    end

    describe '#run' do
      let(:executor) do
        executor = double
        executor.stub(:shutdown)

        executor
      end

      before(:each) do
        S3ObjectsSync::AWS.stub(:objects_from).and_return([])
        processor.stub(:executor).and_return(executor)
      end

      it 'calls S3ObjectsSync::AWS::objects_from' do
        S3ObjectsSync::AWS.should_receive(:objects_from).with('awesome-bucket', 'photos')

        processor.run
      end

      it 'creates X S3ObjectsSync::TransferAsynchronously' do
        S3ObjectsSync::TransferAsynchronously.should_receive(:new).exactly(3).times
        S3ObjectsSync::AWS.stub(:objects_from).and_return([double, double, double])
        processor.stub(:execute_asynchronously)

        processor.run
      end

      it 'calls X times #execute_asynchronously' do
        S3ObjectsSync::AWS.stub(:objects_from).and_return([double, double, double])
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
