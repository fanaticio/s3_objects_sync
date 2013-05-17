java_import java.util.concurrent.Executors
java_import java.util.concurrent.FutureTask

require 'aws'
require 's3_objects_sync/aws'
require 's3_objects_sync/logger'
require 's3_objects_sync/transfer_asynchronously'

module S3ObjectsSync
  class Processor
    def initialize(configuration)
      @configuration = configuration
    end

    def execute_asynchronously(transfer)
      executor.execute(FutureTask.new(transfer))
    end

    def executor
      @executor ||= Executors.newFixedThreadPool(@configuration[:max_threads])
    end

    def run
      Logger.info('Start sync...')

      AWS::objects_from(@configuration[:buckets][:source], 'photos').each do |object|
        execute_asynchronously(TransferAsynchronously.new(object, @configuration))
      end

      executor.shutdown
    end
  end
end
