java_import java.util.concurrent.Executors
java_import java.util.concurrent.FutureTask

require 'aws'
require 's3_photos_syncing/aws'
require 's3_photos_syncing/logger'
require 's3_photos_syncing/transfer_asynchronously'

module S3PhotosSyncing
  class Processor
    MAX_THREAD_COUNT = 42

    def initialize(configuration)
      @configuration = configuration
    end

    def configure_aws
      ::AWS.config(@configuration['authentication'])
    end

    def execute_asynchronously(transfer)
      executor.execute(FutureTask.new(transfer))
    end

    def executor
      @executor ||= Executors.newFixedThreadPool(MAX_THREAD_COUNT)
    end

    def run
      Logger.info('Start syncing...')

      configure_aws
      AWS::objects_from(@configuration['buckets']['source'], 'photos').each do |object|
        execute_asynchronously(TransferAsynchronously.new(object, @configuration['buckets']))
      end

      executor.shutdown
    end

  end
end
