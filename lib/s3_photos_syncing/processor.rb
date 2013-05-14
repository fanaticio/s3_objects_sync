java_import java.util.concurrent.Executors
java_import java.util.concurrent.FutureTask

require 'aws'
require 's3_photos_syncing/aws'
require 's3_photos_syncing/logger'
require 's3_photos_syncing/transfer_asynchronously'

module S3PhotosSyncing
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
      Logger.info('Start syncing...')

      AWS::objects_from(@configuration[:buckets][:source], 'photos').each do |object|
        execute_asynchronously(TransferAsynchronously.new(object, @configuration))
      end

      executor.shutdown
    end
  end
end
