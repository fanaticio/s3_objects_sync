java_import java.util.concurrent.Callable
require 's3_photos_syncing/aws'

module S3PhotosSyncing
  class TransferAsynchronously
    include Callable

    def initialize(object, options)
      @object      = object
      @source      = options[:buckets][:source]
      @destination = options[:buckets][:destination]
      @force       = options[:force]
    end

    def call
      AWS::transfer(@object, from: @source, to: @destination, force: @force)
    end
  end
end
